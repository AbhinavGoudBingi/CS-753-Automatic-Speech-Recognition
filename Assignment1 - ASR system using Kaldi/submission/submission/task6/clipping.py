import os
import sys

n = 0

def s_indices(files,phrase):
    s = ",".join(utterances[files])
    p = ",".join(phrase)
    i = s.find(p)
    global n
    time_s = ([],[])
    while i != -1:
        index = len(s[0:i].split(","))-1
        fi = 0
        merge_str = ""
        for j in range(len(phrase)):
            os.system('sox corpus/data/wav/{}/{}.wav outputaudio/temp{}.wav trim {} {}'.format(files.split("_")[0],files,str(fi),start_times[files][index+j],end_times[files][index+j]))
            merge_str = merge_str+' outputaudio/temp{}.wav'.format(str(fi))
            fi += 1
        os.system("sox "+merge_str+" outputaudio/wave{}.wav".format(str(n)))
        for k in range(fi):
            os.system("rm outputaudio/temp{}.wav".format(str(k)))
        n += 1
        i = s.find(p, i+1)

utterances = {}
start_times = {}
end_times = {}

for line in open("word_time.txt","r"):
    words = (line.strip()).split(" ")
    if words[0] in utterances:
        utterances[words[0]].append(words[4])
        start_times[words[0]].append(words[2])
        end_times[words[0]].append(words[3])
    else:
        utterances[words[0]] = [words[4]]
        start_times[words[0]] = [words[2]]
        end_times[words[0]] = [words[3]]

phrase = str(" ".join(sys.argv[1:]))

word_phrase = (phrase.strip()).split(" ")

for files in utterances:
    s_indices(files,word_phrase)