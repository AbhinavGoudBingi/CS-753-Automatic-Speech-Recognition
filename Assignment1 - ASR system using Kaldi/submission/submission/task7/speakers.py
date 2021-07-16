import sys
import os

speakers = set({})

for line in open(sys.argv[1],"r"):
	speakers.add((line.split(" ")[0]).split("_")[0])
	pass
os.system("echo {} > speakers.txt".format(" ".join(list(speakers))))