# Convert PostgreSQL (BAG/3D) data to CityGML LOD1
# 
# Inspired by https://gis.stackexchange.com/questions/230994/creating-simple-citygml-3d-models-based-on-2d-shapefiles-alkis-shp2gml-using-p
#
# This Postgis version works on data from http://3dbag.bk.tudelft.nl/
# 
# tvijlbrief@gmail.com

# gemeentecode = '0034' # almere
gemeentecode = '0981' # vaals
# gemeentecode = '0308' # baarn
# gemeentecode = '0424' # muiden

to_0 = True

import os
import psycopg2

import shapely
from shapely import wkb

import geos
from shapely.geometry import LineString

from lxml import etree, objectify

connection = psycopg2.connect(user="tom",
                              password=os.getenv("PGPASS"),
                              host=os.getenv("PGHOST", "localhost"),
                              sslmode='require',
                              port=os.getenv("PGPORT", "5432"),
                              database="bag3d")

class reg(object):
    def __init__(self, cursor, row):
        for (attr, val) in zip((d[0] for d in cursor.description), row) :
            setattr(self, attr, val)

def build_gml_main():
    # define Namespaces
    ns_core = "http://www.opengis.net/citygml/1.0"
    ns_bldg = "http://www.opengis.net/citygml/building/1.0"
    ns_gen = "http://www.opengis.net/citygml/generics/1.0"
    ns_gml = "http://www.opengis.net/gml"
    ns_xAL = "urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"
    ns_xlink = "http://www.w3.org/1999/xlink"
    ns_xsi = "http://www.w3.org/2001/XMLSchema-instance"
    ns_schemaLocation = "http://www.opengis.net/citygml/1.0 http://schemas.opengis.net/citygml/1.0/cityGMLBase.xsd http://www.opengis.net/citygml/building/1.0 http://schemas.opengis.net/citygml/building/1.0/building.xsd http://www.opengis.net/citygml/generics/1.0 http://schemas.opengis.net/citygml/generics/1.0/generics.xsd http://www.opengis.net/gml http://schemas.opengis.net/gml/3.1.1/base/gml.xsd"

    #ns_core, ns_bldg, ns_gen, ns_gml, ns_xAL, ns_xlink, ns_xsi

    nsmap = {
        'core': ns_core,
        'bldg': ns_bldg,
        'gen': ns_gen,
        'gml': ns_gml,
        'xAL': ns_xAL,
        'xlink': ns_xlink,
        'xsi': ns_xsi,
    }

    # Main Element
    cityModel = etree.Element("{%s}CityModel" % ns_core, nsmap=nsmap)
    # Add branch
    description = etree.SubElement(cityModel, "{%s}description" % ns_gml)
    description.text = "Demo data from http://3dbag.bk.tudelft.nl/"
    name = etree.SubElement(cityModel, "{%s}name" % ns_gml)
    name.text = "LoD_1"
    # Add branch
    bounded = etree.SubElement(cityModel, "{%s}boundedBy" % ns_gml)
    # Add branch to a branch
    envelop = etree.SubElement(
        bounded, "{%s}Envelope" % ns_gml, srsName="EPSG:7415", srsDimension="3")
        # bounded, "{%s}Envelope" % ns_gml, srsName="EPSG:28992", srsDimension="3")

    lb = etree.SubElement(envelop, "{%s}lowerCorner" %
                          ns_gml, srsDimension="3")
    lb.text = ''
    ub = etree.SubElement(envelop, "{%s}upperCorner" %
                          ns_gml, srsDimension="3")
    ub.text = ''

    cursor = connection.cursor()
    cursor.execute(
        "select identificatie, geovlak, \
            \"roof-0.50\" as roof50, \
            \"ground-0.50\" as ground50 \
        from \"3dbag\".pand3d where height_valid \
            and gemeentecode = '" + gemeentecode + "'")

    # Add buildings
    cityModel, point_max, point_min = iteration_buildings(
        cityModel, cursor, ns_core, ns_bldg, ns_gen, ns_gml, ns_xAL, ns_xlink, ns_xsi)

    lb.text = str(point_min[0]) + ' ' + \
        str(point_min[1]) + ' ' + str(point_min[2])
    ub.text = str(point_max[0]) + ' ' + \
        str(point_max[1]) + ' ' + str(point_max[2])

    pretty = etree.tostring(cityModel, pretty_print=True)
    # print(pretty)

    # Save File
    outFile = open('3dbag-' + gemeentecode + '.xml', 'w')
    outFile.write(pretty.decode('utf-8'))
    print('done')


def iteration_buildings(cityModel, cursor, ns_core, ns_bldg, ns_gen, ns_gml, ns_xAL, ns_xlink, ns_xsi):
    # lower corner
    point_min = None
    # upper corner
    point_max = None
    count = 0

    for i_build in cursor.fetchall():
        r = reg(cursor, i_build)
        # print(r.identificatie, r.ground50, r.roof50)
        if not r.ground50:
            continue
        if to_0:
            r.roof50 -= r.ground50
            r.ground50 = 0
        count += 1
        cityObject = etree.SubElement(
            cityModel, "{%s}cityObjectMember" % ns_core)

        iepoly = wkb.loads(r.geovlak, hex=True)
        points_2D = iepoly.exterior.coords

        # for Citygml the lower and upper limit of all buildings are needed
        point_min, point_max = find_lower_upper_corner(
            points_2D, r.roof50, point_min, point_max)

        polygon = polygon_calculation(r, points_2D, False)

        for iring in iepoly.interiors:
            for surf in polygon_calculation(r, iring.coords, True):
                polygon.insert(0, surf)

        # Add XML of a building
        bldg = etree.SubElement(cityObject, "{%s}Building" % ns_bldg, {
                                "{%s}id" % ns_gml: 'ID' + r.identificatie})
        creationDate = etree.SubElement(bldg, "{%s}creationDate" % ns_core)
        creationDate.text = '2019-01-01'
        externalReference = etree.SubElement(
            bldg, "{%s}externalReference" % ns_core)
        informationSystem = etree.SubElement(
            externalReference, "{%s}informationSystem" % ns_core)
        informationSystem.text = "https://github.com/tomtor/k8s/blob/master/DT/build.py"
        externalObject = etree.SubElement(
            externalReference, "{%s}externalObject" % ns_core)
        name = etree.SubElement(externalObject, "{%s}name" % ns_core)
        name.text = 'ID' + r.identificatie

        measuredHeight = etree.SubElement(
            bldg, "{%s}measuredHeight" % ns_bldg, uom="urn:adv:uom:m")
        measuredHeight.text = str(r.roof50 - r.ground50)

        # Add the 3d polygon
        lod1Solid = etree.SubElement(bldg, "{%s}lod1Solid" % ns_bldg)
        Solid = etree.SubElement(lod1Solid, "{%s}Solid" % ns_gml)
        exterior = etree.SubElement(Solid, "{%s}exterior" % ns_gml)
        CompositeSurface = etree.SubElement(
            exterior, "{%s}CompositeSurface" % ns_gml)

        polycnt = 0
        for poly in polygon:
            surfaceMember = etree.SubElement(
                CompositeSurface, "{%s}surfaceMember" % ns_gml)
            xmlpol = etree.SubElement(surfaceMember, "{%s}Polygon" % ns_gml, {
                                       "{%s}id" % ns_gml: 'P' + r.identificatie + '_' + str(polycnt)})
            exterior = etree.SubElement(xmlpol, "{%s}exterior" % ns_gml)
            LinearRing = etree.SubElement(exterior, "{%s}LinearRing" % ns_gml)

            for point in poly:
                pos = etree.SubElement(
                    LinearRing, "{%s}pos" % ns_gml, srsDimension="3")
                pos.text = str(point[0]) + ' ' + \
                    str(point[1]) + ' ' + str(point[2])

            if polycnt >= len(polygon) - 2:
                for inner in iepoly.interiors:
                    print("add inner ring", len(polygon))
                    interior = etree.SubElement(xmlpol, "{%s}interior" % ns_gml)
                    LinearRing = etree.SubElement(interior, "{%s}LinearRing" % ns_gml)
                    for point in inner.coords:
                        pos = etree.SubElement(
                            LinearRing, "{%s}pos" % ns_gml, srsDimension="3")
                        pos.text = str(point[0]) + ' ' + str(point[1]) + ' ' \
                            + str(r.ground50 if polycnt ==
                                  len(polygon) - 2 else r.roof50)
            polycnt += 1

        if count % 500 == 0:
            print('done: ' + str(count) + ' objects')

    # print etree.tostring(cityModel, pretty_print=True)
    return cityModel, point_max, point_min


def polygon_calculation(tuple, points_2D, inner):

    polygon = []
    ground_height = tuple.ground50
    roof_height = tuple.roof50

    for point_A, point_B in zip(points_2D[:-1], points_2D[1:]):
        surface = []
        surface.append((point_A[0], point_A[1], roof_height))
        surface.append((point_B[0], point_B[1], roof_height))
        surface.append((point_B[0], point_B[1], ground_height))
        surface.append((point_A[0], point_A[1], ground_height))
        surface.append((point_A[0], point_A[1], roof_height))

        polygon.append(surface)

        # print(point_A, point_B)

    # for inner rings we do not have a roof and ground surface
    if inner:
        return polygon
    
    # add roof, add ground
    roof = []
    ground = []
    for point in points_2D:
        roof.append((point[0], point[1], roof_height))
        ground.append((point[0], point[1], ground_height))
    polygon.append(ground)
    polygon.append(roof)

    return polygon


def find_lower_upper_corner(points_2D, dachhoehe, point_min, point_max):
    # compare the given points with the saved lower and upper limit
    # if lower or upper points exist, overwrite the saved ones
    points_2D_list = list(points_2D)
    if point_min is None:
        point_min = list(points_2D_list[0] + (0,))
        point_max = list(points_2D_list[0] + (0,))

    for point in points_2D_list:
        if point_min[0] > point[0]:
            point_min[0] = point[0]
        if point_max[0] < point[0]:
            point_max[0] = point[0]
        if point_min[1] > point[1]:
            point_min[1] = point[1]
        if point_max[1] < point[1]:
            point_max[1] = point[1]
        if point_max[2] < dachhoehe:
            point_max[2] = dachhoehe
    return point_min, point_max


build_gml_main()
