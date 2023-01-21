from fastapi import FastAPI
import sched, time

app = FastAPI()
s = sched.scheduler(time.time, time.sleep)


avau_mods = {}
frame = 1


@app.get("/select_mode/{mode}")
def select_mode(mode: str):
    global avau_mods
    if mode in avau_mods and len(avau_mods[mode]) > 0:
        return {"req": mode, "data": avau_mods[mode]}
    return {"req": mode, "error": mode in avau_mods}


@app.get("/iamserver/{mode}/{ip}/{port}")
def iam_server(mode: str, ip: str, port: int):
    global avau_mods
    if not mode in avau_mods:
        avau_mods[mode] = []

    for i in avau_mods[mode]:
        if i["adress"] == ip and i["port"] == port:
            i["time"] = 10
            return

    avau_mods[mode].append({
        "adress": ip,
        "port": port,
        "time": 10
    })

@app.get("/deletserver/{mode}/{ip}/{port}")
def delet_server(mode: str, ip: str, port: int):
    global avau_mods
    if mode in avau_mods:
        for i in range(len(avau_mods[mode])):
            if avau_mods[mode][i]["adress"] == ip and avau_mods[mode][i]["port"] == port:
                avau_mods[mode].pop(i)




def event(sc):
    for mods in avau_mods:
        for i in range(len(mods)):
            mods[i]["time"] -= 1

            if mods[i]["time"] <= 0:
                mods.pop(i)
#Наговнокодили постоянный вызов фунции
    sc.enter(frame, 1, event, (sc,))
s.enter(frame, 1, event, (s,))
