use postgres::{Connection, Error, TlsMode};
use rand::Rng;
use std::time::Instant;

use std::{thread, time};

fn main() -> Result<(), Error> {
    let url = "postgresql://tom@localhost:30779/brk";
    let conn = Connection::connect(url, TlsMode::None).unwrap();
    let mut rng = rand::thread_rng();

    let count = 1000;
    let range = 100_000;

    for _ in 1..=5 {

        let stmt = conn.prepare("SELECT lokaalid FROM perceel WHERE ogc_fid = $1")?;
        let now = Instant::now();
        for _ in 1..count {
            let fid: i32 = rng.gen_range(1, range);
	    for row in &stmt.query(&[&fid]).unwrap() {
		let lid: i64 = row.get("lokaalid");
		//println!("{}", lid)
	    }
	    //thread::sleep(time::Duration::from_millis(100));
        }
        println!("{}", now.elapsed().as_secs_f32());

        let stmt = conn.prepare_cached("SELECT lokaalid FROM perceel WHERE ogc_fid = $1")?;
        let now = Instant::now();
        for _ in 1..count {
            let fid: i32 = rng.gen_range(1, range);
            let _row = stmt.query(&[&fid])?;
        }
        println!("{}", now.elapsed().as_secs_f32());

        println!("=============================");
    }

    Ok(())
}
