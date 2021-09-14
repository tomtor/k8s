-- View: public.diffbag

DROP VIEW public.diffbagarea cascade;

CREATE OR REPLACE VIEW public.diffbagarea
 AS
 SELECT a.ogc_fid,
    a.gml_id,
    a.objectbegintijd,
    a."identificatie.namespace",
    a."identificatie.lokaalid",
    a.tijdstipregistratie,
    a.eindregistratie,
    a.lv_publicatiedatum,
    a.bronhouder,
    a.inonderzoek,
    a.relatievehoogteligging,
    a.bgt_status,
    a.identificatiebagpnd,
    a."nummeraanduidingreeks_1.tekst",
    a."nummeraanduidingreeks_1.positie_1.hoek",
    a."nummeraanduidingreeks_1.identificatiebagvbolaagstehuisnummer",
    a."nummeraanduidingreeks_1.identificatiebagvbohoogstehuisnummer",
    a.objecteindtijd,
    a."nummeraanduidingreeks_2.tekst",
    a."nummeraanduidingreeks_2.positie_1.hoek",
    a."nummeraanduidingreeks_2.identificatiebagvbolaagstehuisnummer",
    a."nummeraanduidingreeks_2.identificatiebagvbohoogstehuisnummer",
    a."nummeraanduidingreeks_3.tekst",
    a."nummeraanduidingreeks_3.positie_1.hoek",
    a."nummeraanduidingreeks_3.identificatiebagvbolaagstehuisnummer",
    a."nummeraanduidingreeks_3.identificatiebagvbohoogstehuisnummer",
    a.plus_status,
    a.wkb_geometry,
    b.identificatie as bag_match_identificatie
   FROM pand a
     -- JOIN bag_extract_deelbestand__antwoord_producten_lvc_product_pand b ON st_overlaps(st_snaptogrid(a.wkb_geometry,0.1), st_snaptogrid(b.pandgeometrie,0.1))
     JOIN bag_pand b ON st_overlaps(a.wkb_geometry,b.pandgeometrie)
  -- WHERE abs(st_perimeter(a.wkb_geometry) - st_perimeter(b.pandgeometrie)) > 1::double precision
  WHERE abs(st_area(a.wkb_geometry) - st_area(b.pandgeometrie)) > 0.1::double precision
    and a.identificatiebagpnd = b.identificatie::bigint;

-- ALTER TABLE public.diffbag OWNER TO postgresadmin;

-- GRANT ALL ON TABLE public.diffbag TO postgresadmin;
GRANT ALL ON TABLE public.diffbagarea TO PUBLIC;


SET max_parallel_workers_per_gather = 1;

create materialized view diffbagareamat as select * from diffbagarea order by wkb_geometry;

CREATE INDEX diffbagareamat_wkb_geometry_geom_idx ON public.diffbagareamat USING gist (wkb_geometry) TABLESPACE pg_default;

CREATE INDEX diffarea_ogc_id ON public.diffbagareamat USING btree (ogc_fid ASC NULLS LAST) INCLUDE(ogc_fid) TABLESPACE pg_default;

-- REFRESH MATERIALIZED VIEW diffbagareamat;
vacuum analyze diffbagareamat;
