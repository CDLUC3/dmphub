#
# Just a collection of useful scripts for the DMPHub
# ---------------------------------------------------
#

# Nbr of DMPs created by `yyyy-mm`
SELECT SUBSTRING(DATE(created_at), 1, 7) creation_month, COUNT(id) nbr_dmps
FROM data_management_plans
GROUP BY creation_month ORDER BY creation_month DESC;
