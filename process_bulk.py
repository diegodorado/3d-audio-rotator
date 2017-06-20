import os
import argparse
import multiprocessing
import subprocess
import time

parser = argparse.ArgumentParser(description='Bulk Audio Proccess')
parser.add_argument('inputPath')
parser.add_argument('outputPath')
parser.add_argument('rotationFreq', type=float)
parser.add_argument('rotationPhase', type=float)

args = parser.parse_args()

def work(file):
    cmd = 'chuck -s process.ck:' + os.path.join(args.inputPath, file)
    cmd += ':' + os.path.join(args.outputPath, file)
    cmd += ':' + str(args.rotationFreq)
    cmd += ':' + str(args.rotationPhase)
    return subprocess.call(cmd, shell=True)

if __name__ == '__main__':
    start_time = time.time()
    # Passing None will use cpu_count processes
    pool = multiprocessing.Pool(None)
    files = os.listdir(args.inputPath)
    results = pool.map(work, files)
    elapsed_time = time.time() - start_time
    #print results
    print "Elapsed time: " + str(round(elapsed_time, 4))
