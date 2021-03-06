#![feature(proc_macro_hygiene, decl_macro)]

use std::sync::atomic::{AtomicUsize, Ordering};

#[macro_use]
extern crate rocket;
#[macro_use]
extern crate rocket_contrib;

use rocket_contrib::databases::postgres;

#[database("pg_brk")]
struct BrkDbConn(postgres::Connection);

#[get("/")]
fn health() -> &'static str {
    "ok"
}

static COUNT: AtomicUsize = AtomicUsize::new(0);

#[get("/lokaalid/<ogc_fid>")]
fn lokaalid(conn: BrkDbConn, ogc_fid: i32) -> String {
    let count = COUNT.fetch_add(1, Ordering::Relaxed) + 1;
    if count % 1000 == 0 {
        println!("{}", count);
    }

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

fn build_rocket() -> rocket::Rocket {
    rocket::ignite()
        .attach(BrkDbConn::fairing())
        .mount("/", routes![health, lokaalid])
}

fn main() {
    build_rocket().launch();
}

#[cfg(test)]
mod tests;
