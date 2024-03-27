from fastapi import APIRouter, HTTPException, Request
import persistence.computerDB as computerDB
router = APIRouter()
@router.get("/")
async def computerInfo():
    result = await computerDB.getAllComputerInfo()
    return result
@router.get("/info/{pcID}")
async def compterInfoDetail(pcID:str):
    result = await computerDB.getAllComputerInfo()
    if not pcID.isnumeric():
        raise HTTPException(status_code=400, detail="Invalid input value, cannot find id")
    pcID = int(pcID)
    if pcID<0 or pcID> len(result):
        raise HTTPException(status_code=400, detail="Invalid input value, cannot find id")
    return result[pcID-1]
@router.post("/info/{pcID}")
async def updateComputerDetail(pcID:str,req:Request):
    if not pcID.isnumeric():
        raise HTTPException(status_code=400, detail="Invalid input value, cannot find id")
    pcID = int(pcID)
    req = await req.json()
    key = ["id","brand","buyDate","khuvuc","config"]
    try:
        data = [req[i] for i in key]
    except:
        raise HTTPException(400,"invalid body key")
    try:
        res = await computerDB.updateComputerInfo(pcID,data)
        return res
    except Exception as err:
        if type(err) == HTTPException:
            raise HTTPException(status_code=400, detail=err.detail)
        else:
            raise HTTPException(status_code=500,detail="internal error")
@router.post("/add")
async def addNewComputer(req:Request):
    print("this")
    req = await req.json()
    key = ["brand","buyDate","khuvuc","config"]
    try:
        data = [req[i] for i in key]
    except:
        raise HTTPException(400,"invalid body key")
    try:
        res = await computerDB.addComputer(data)
        return res
    except Exception as err:
        if type(err) == HTTPException:
            raise HTTPException(status_code=400, detail=err.detail)
        else:
            raise HTTPException(status_code=500,detail="internal error")