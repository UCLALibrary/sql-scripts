select patron_id,
normal_last_name, 
patron_barcode, patron_group_display--, uc_community
from vger_support.ucladb_patrons p
where exists (
select * from vger_support.ucladb_patrons
where patron_id = p.patron_id
and uc_community != p.uc_community
)
