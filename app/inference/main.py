from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Inference API", version="1.0")

class InferenceRequest(BaseModel):
    values: list[float]

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/infer")
def infer(req: InferenceRequest):
    return {
        "prediction": sum(req.values),
        "count": len(req.values)
    }
