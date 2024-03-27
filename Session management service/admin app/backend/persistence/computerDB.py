from fastapi import HTTPException
import mysql.connector
from persistence.database_config import DBCONFIG


async def checkPCID(pcID,cursor)->bool:
    cursor.execute(f'select checkPCID({pcID})')
    valid = int(cursor.fetchone()[0])
    return True if valid==1 else False
async def getAllComputerInfo():
    connection = mysql.connector.connect(**DBCONFIG)
    try:
        with connection.cursor() as cursor:
            cursor.callproc('getAllComputerInfo')
            connection.commit()
            message = []
            for data in cursor.stored_results():
                results = data.fetchall()
            connection.close()
            for data in results:
                message.append({
                    'id':data[0],
                    'brand':data[1],
                    'buyDate':data[2],
                    'khuvuc':data[3],
                    'config': data[4],
                    'price':data[5],
                    'bonus':data[6]
                })
            return message
    except Exception as e:
        print(e)
        connection.close()
        return []
async def updateComputerInfo(pcID:int,data):
    connection = mysql.connector.connect(**DBCONFIG)
    try:
        with connection.cursor() as cursor:
            if not await checkPCID(pcID,cursor):
                raise HTTPException(400,"invalid id")
            cursor.callproc("updateComputerInfo",args=data)
            connection.commit()
            connection.close()
            return {'message':'OK'}
    except Exception as err:
        connection.close()
        if type(err) != HTTPException:
            raise HTTPException(400,"can not update the record")
        else:
            raise HTTPException(400,err.detail)
async def addComputer(data):
    connection = mysql.connector.connect(**DBCONFIG)
    try:
        with connection.cursor() as cursor:
            cursor.callproc("addComputer",args=data)
            connection.commit()
            connection.close()
            return {'message':'OK'}
    except Exception as err:
        connection.close()
        if type(err) != HTTPException:
            raise HTTPException(400,"can not add the record")
        else:
            raise HTTPException(400,err.detail)
    