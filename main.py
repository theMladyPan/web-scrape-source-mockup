from fastapi import FastAPI
from pydantic import BaseModel, RootModel
import json


class JobModel(BaseModel):
    cron: str
    alias: str
    timeout: int
    ignore: bool
    depth: int


JobsModel = RootModel[dict[str, JobModel]]

with open("config.json", "r") as file:
    jobs_dict = json.load(file)


import time

ts = time.perf_counter_ns()
jobs: JobsModel = JobsModel.model_validate(jobs_dict)
te = time.perf_counter_ns()
print(f"Loaded jobs in {te - ts}ns, {(te-ts)/10**3:.03}us")


app = FastAPI()


@app.get("/")
async def root() -> JobsModel:
    return jobs
