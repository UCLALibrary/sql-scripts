/*  Subject, class and selected bib info for specific languages:
      ger	German	465249
      spa	Spanish	413250
      fre	French	394797
      ita	Italian	151438
      rus	Russian	138982

      ara	Arabic	115384
      por	Portuguese	102991
      heb	Hebrew	66410
      lat	Latin	54549
      dut	Dutch	39760
      swe	Swedish	27047
      pol	Polish	24894
      tur	Turkish	24713
      per	Persian	24658
      hun	Hungarian	20249

      dan	Danish	17298
      arm	Armenian	17032
      nor	Norwegian	13457
      fin	Finnish	9710
      cat	Catalan	9487
      yid	Yiddish	9246
      ota	Turkish, Ottoman	3690
      urd	Urdu	4388
      aze	Azerbaijani	1794
      kur	Kurdish	1061

    RR-318
*/
with bibs as (
  select 
    bib_id
  , language
  , pub_place
  , substr(begin_pub_date, 1, 3) || 'x' as decade
  , substr(bib_format, 1, 1) as rec_type
  , substr(bib_format, 2, 1) as bib_level
  from bib_text
  where language = 'ara'
)
, details as (
  select
    b.bib_id
  --, b.pub_place
  , replace(ucladb.norm2(vger_support.unifix(b.pub_place)), ' ', '') as pub_place
  , b.decade
  , b.rec_type
  , b.bib_level
  -- Initial letters of 050 $a (if present) = LC Class
  , ( select regexp_substr(subfield, '^[A-Z]+')
      from vger_subfields.ucladb_bib_subfield
      where record_id = b.bib_id
      and tag = '050a'
      and rownum < 2
    ) as LC
  , vger_support.unifix(ucladb.GetTag(bib_id, 'B', '650', 1)) as f650_1
  , vger_support.unifix(ucladb.GetTag(bib_id, 'B', '650', 2)) as f650_2
  from bibs b
)
select decade, pub_place, rec_type, bib_level, lc, f650_1, f650_2, count(*) as num
--select count(*) as num
from details
group by decade, pub_place, rec_type, bib_level, lc, f650_1, f650_2
order by num desc
;

-- Counts of bibs by language for reference
select 
  bt.language as code
, mlc.language as language
, count(*) as num
from bib_text bt
left outer join vger_support.marc_language_codes mlc on bt.language = mlc.code
where bt.language != 'eng' 
group by bt.language, mlc.language
order by num desc, bt.language
;


-- Workaround for large datasets: create tmp table via vger_sqlplus_run
select count(*) from vger_report.tmp_rr_318;

select *
from vger_report.tmp_rr_318
order by num desc;

drop table vger_report.tmp_rr_318 purge;
