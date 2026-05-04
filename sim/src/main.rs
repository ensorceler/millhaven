use std::{ process::exit, thread };

use axum::routing::get;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let mut app = axum::Router::new();
    app = app.route("/", get(hello));

    let listener;
    match TcpListener::bind("0.0.0.0:3000").await {
        Ok(t) => {
            listener = t;
        }
        Err(e) => {
            eprintln!("Error:{}", e);
            exit(1);
        }
    }

    axum::serve(listener, app).await.unwrap();
}

async fn hello() -> &'static str {
    "hello world"
}
