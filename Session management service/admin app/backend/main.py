from fastapi import *
import api.computer as computer
import uvicorn
app = FastAPI()
app.include_router(computer.router,prefix='/computer')

if __name__ == "__main__":
    # app.include_router(computer.router,prefix='/computer')
    uvicorn.run("main:app", host="localhost", port=9999,reload=True)
    # uvicorn.run(app, host="localhost", port=9999)