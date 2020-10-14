#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use]
extern crate rocket;
#[macro_use]
extern crate rocket_contrib;

use rocket_contrib::databases::postgres;

#[database("pg_brk")]
struct BrkDbConn(postgres::Connection);

#[get("/health")]
fn health() -> &'static str {
    "ok"
}

#[get("/lokaalid/<ogc_fid>")]
fn lokaalid(conn: BrkDbConn, ogc_fid: i32) -> String {
    let stmt = conn
        .prepare_cached("SELECT lokaalid FROM perceel WHERE ogc_fid = $1")
        .unwrap();
    let rows = stmt.query(&[&ogc_fid]).unwrap();
    if rows.is_empty() {
        "?".to_string()
    } else {
        let lid: i64 = rows.get(0).get("lokaalid");
        format!("{}", lid)
    }
}

fn main() {
    rocket::ignite()
        .attach(BrkDbConn::fairing())
        .mount("/", routes![health, lokaalid])
        .launch();
}
