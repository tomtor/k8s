use postgres::{Client, Error, NoTls};
use rand::Rng;
use std::time::Instant;

fn main() -> Result<(), Error> {
    let mut client = Client::connect("postgresql://tom@localhost:30779/brk", NoTls)?;
    let mut rng = rand::thread_rng();

    let count = 1000;
    let range = 10_000;

    for _ in 1..=5 {
        let now = Instant::now();

        for _ in 1..count {
            let fid: i32 = rng.gen_range(1, range);
            let _row =
                client.query_one("SELECT lokaalid FROM perceel where ogc_fid = $1", &[&fid])?;
        }
        println!("{}", now.elapsed().as_secs_f32());

        let stmt = client.prepare("SELECT lokaalid FROM perceel WHERE ogc_fid = $1")?;

        let now = Instant::now();
        for _ in 1..count {
            let fid: i32 = rng.gen_range(1, range);
            let _row = client.query_one(&stmt, &[&fid])?;
	    // let lid: i64 = row.get("lokaalid");
	    // println!("{}", lid);
        }
        println!("{}", now.elapsed().as_secs_f32());
        println!("=============================");
    }

    Ok(())
}
