Ah, the joys of Voyager indexing, compounded with what may be Martha Yee's particular views.

First, relevance ranking is not being used here - the search code in the OPAC is FTIT, not FTIT* - so 245 $a weighing is irrelevant (ha).  Editing the search URL to use FTIT* changes the order of the first few records, but the first Citizen Kane is still 4th.  And checking the Sysadmin help for "Search Indexes Field Weighting", it seems relevance only applies to keyword searches... and FTIT is a composite left-anchored index.  So I'm not 100% sure, but I believe that relevance does not matter at all for this search (despite being able to do it in the UI, with results as described).

Sysadmin doesn't show enough details so checking the database:

{noformat}
select * from filmntvdb.searchparm where searchcode = 'FTIT';
-- General info is useful, but focus on indexrules
IX=C CS=440F~830F~245F~740F~130F~730F~630F~246F 
-- This says the index is Composite (IX=C), and its components are the left-anchored indexes listed.

-- See the definitions of each of the left-anchoreds:
select * from filmntvdb.searchparm where searchcode in ('440F', '830F', '245F', '740F', '130F', '730F', '630F', '246F');

-- 245 $a is part of the 245F index:
245F    FATA title  IX=B AL=245 S+=anp NM=juaih NF=2 1+=1

-- S+=anp means subfields a, n and p are included
{noformat}

So, 245 $a is *included* in the FTIT index.  But what governs sorting?  The searchparm definition says to sort by "Title", but what is "Title"?  bib_text has a 'title' field, but bib_text is not indexed on it.

The SQL source for BIBSORTING_VW suggests that it's the '2451' data in the bib_index table.  Some exploratory queries later and I wind up with this:
{noformat}
select
  bi.*
, ( select normal_heading from filmntvdb.bib_index
    where bib_id = bi.bib_id
    and index_code = '2451'
  ) as normal_title_from_bi
, ( select display_heading from filmntvdb.bib_index
    where bib_id = bi.bib_id
    and index_code = '2451'
  ) as display_title_from_bi
, ( select title from filmntvdb.bib_text
    where bib_id = bi.bib_id
  ) as title
from filmntvdb.bib_index bi
where bi.index_code in ('440F', '830F', '245F', '740F', '130F', '730F', '630F', '246F')
and bi.normal_heading like 'CITIZEN KANE%'
order by normal_heading, normal_title_from_bi
;
{noformat}

This query returns results in the same order as the regular FTIT search in the OPAC.  It returns more rows because I didn't bother de-duping, which the OPAC does - I wanted to see all of the relevant data.

So: from this, it appears that left-anchored searches are sorted first by the bib_index.normal_heading matching the search, then sub-sorted by the corresponding 
'2451' bib_index.normal_heading.  Because of the trailing / in the '245F' index entry, "CITIZEN KANE /" sorts after "CITIZEN KANE" found in some 630 fields.

Why is the trailing / indexed for 245F?  Per the indexrules, the normalization rules used are: NM=juaih
j - Strip spaces on the right
u - Convert to upper case
a - Strip diacritics
i - Strip multiple spaces
h - Strip spaces on the left

Notably missing: 
p - Strip punctuation (NACO rules)

This is not something which can be changed via Sysadmin.  It would require a direct database update (which I can do, safely) and a full headings/left-anchored index rebuild, which would require an hour or so of down-time (these indexes are dropped, then built outside of Oracle, then loaded into Oracle).

FATA should carefully consider the possible ramifications of such a change, which may also be applicable to other indexes - I looked only at the normalization rules for 245F.




