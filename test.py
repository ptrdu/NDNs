import TOSSIM
import sys

t = TOSSIM.Tossim([])
r = t.radio()

f = open("topo.txt","r")
noise = open("meyer-heavy.txt","r")

#t.addChannel("REPO", sys.stdout)
#t.addChannel("CTP",sys.stdout)
#t.addChannel("FIB", sys.stdout)
#t.addChannel("GPS", sys.stdout)
t.addChannel("CS",sys.stdout)
t.addChannel("PIT",sys.stdout)
#t.addChannel("UPPER",sys.stdout)
#t.addChannel("ROUTE",sys.stdout)
#t.addChannel("TEST",sys.stdout)
#t.addChannel("PoolP",sys.stdout)
#t.addChannel("QueueC",sys.stdout)
#fLines = f.readlines()
#noiseLines = noise.readlines()
for line in f:
    s = line.split()
    if s:
        r.add(int(s[0]),int(s[1]),float(s[2]))
f.close()
      
for line in noise:
    str1 = line.strip()
    if str1:
        val = int(str1)
        for i in range(1,21):
            t.getNode(i).addNoiseTraceReading(val)
noise.close()
            
for i in range(1,21):
    t.getNode(i).createNoiseModel()
        
for i in range(1,21):
    m = t.getNode(i)
    m.bootAtTime(4 * t.ticksPerSecond() + 242119)


while 1: 
    t.runNextEvent()        
