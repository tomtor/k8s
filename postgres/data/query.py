import requests
import sys

url = 'http://localhost:5000/graphql'

query = """
query {allPerceels(first:1000) {
  edges {
    node {
      lokaalid
      begingeldigheid
      tijdstipregistratie
      volgnummer
      code
      waarde
      kadastraleaanduidingcode
      kadastralegemeente
      sectie
      perceelnummer
      akrkadastralegemeentecode
      akrkadastralegemeentecodewaarde
      kadastralegrootte
      kadastralegroottecode
      kadastralegroottewaarde
      perceelnummerrotatie
      deltax
      deltay
      begrenzingperceel { geojson }
    }
    cursor
  }
  pageInfo {
    endCursor
    hasNextPage
  }
}}
"""

headers = {'Content-type': 'application/graphql'}

def output_edges(r):
    for t in r:
        print(t['node'])

def main():
    q = query
    response = requests.post(url, headers=headers, data=q)
    r = response.json()
    # print(r['data']['allPerceels']['edges'])
    output_edges(r['data']['allPerceels']['edges'])
    count = 1000
    
    while r['data']['allPerceels']['pageInfo']['hasNextPage']:
        print(count, file=sys.stderr)
        qnew = q.replace('first:1000', 'first:1000 ' + 'after:"' +
            r['data']['allPerceels']['pageInfo']['endCursor'] + '"')
        # print(qnew)
        response = requests.post(url, headers=headers, data=qnew)
        r = response.json()
        output_edges(r['data']['allPerceels']['edges'])
        count += 1000


if __name__ == "__main__":
    main()

