#[cfg(test)]
mod simple {
    use crate::build_rocket;
    use rocket::http::Status;
    use rocket::local::Client;

    #[test]
    fn root() {
        let client = Client::new(build_rocket()).expect("valid rocket instance");
        let mut response = client.get("/").dispatch();
        assert_eq!(response.status(), Status::Ok);
        assert_eq!(response.body_string(), Some("ok".into()));
    }
}

#[cfg(test)]
mod database {
    use crate::build_rocket;
    use rocket::http::Status;
    use rocket::local::Client;

    #[test]
    fn lokaalid() {
        let client = Client::new(build_rocket()).expect("valid rocket instance");
        let mut response = client.get("/lokaalid/5").dispatch();
        assert_eq!(response.status(), Status::Ok);
        // assert_eq!(response.body_string(), Some("60025670000".into()));
        assert_eq!(response.body_string().unwrap().parse::<u64>().err(), None);
    }
}
