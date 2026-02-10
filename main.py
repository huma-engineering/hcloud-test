from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Sample FastAPI App")


class EchoRequest(BaseModel):
    message: str


@app.get("/")
def root():
    return {"message": "Hello from Huma Craft Cloud FastAPI example"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/echo")
def echo(payload: EchoRequest):
    return {"echo": payload.message}
