Enter file contents here
select record_id from vger_subfields.ucladb_bib_subfield
where tag = '650a' and subfield like '%Dance%'
group by record_id, tag having count(*) > 1;

