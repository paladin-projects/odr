import sys
import logging
import signal
from fabric import Connection, Config, task
from invoke.watchers import StreamWatcher
import json
from concurrent.futures import ThreadPoolExecutor
from pprint import pprint

logger = logging.getLogger("odr-fab")
FORMAT = "%(asctime)s %(levelname)s %(name)s %(process)d - - %(message)s"

config_commands = [
        "showsys -d",
        "showversion -b -a",
        "showpd -c",
        "showcage -all",
        "showport",
        "showport -c",
        "showcpg -r",
        "showcpg -sdg",
        "showvv -cpgalloc",
        "showvvcpg"
        ]
perf_commands = [
        "statvlun",
        "statpd -rw",
        "statcmp",
        "statcpu",
        "statport -disk -rw",
        "statport -host -rw",
        "statport -rcfc"
        ]

class CustomOutputWatcher(StreamWatcher):
    def submit(self, stream):
        print(f"Received from remote: {stream.strip()}")
        return []

def config_fetch(system):
    # Setup config for connection
    cfg = Config({
        'run': {
            'watchers': [CustomOutputWatcher()],
        },
    })
    # Create connection to system
    with Connection(host=system["host"], user=system["user"], connect_kwargs={"password": system["password"]}, config=cfg) as conn:
        try:
            result = conn.open()
            logger.info(f"Connection result: {result}")
        except:
            logger.error(f"Cannot connect to {conn.host}")
            print(f"Cannot connect to {conn.host}")
            exit(1)
        logger.info(f"Connected to {system['host']}")
        get_config(conn, "config.out")

    # Run get_config task
    # Save result to file

@task
def get_perfpd(ctx):
    ctx.run("statpd -rw", hide=True)

@task
def get_config(ctx, filename):
    f = open(filename, "w")
    for i in config_commands:
        result = ctx.run(i, hide=True)
        if result.return_code != 0:
            logger.error(f"Command '{i}' failed with return code {result.return_code}")
            logger.error(result.stderr)
        else:
            f.write("----- " + i + " -----\n")
            f.write(result.stdout)
            f.write("\n")
    f.close

def reconfigure(signum, frame):
    logger.info("Reconfiguring...")
    # Reread configuration file
    with open("odr-fab.json") as f:
        newconfig = json.load(f)
    # Compare new configuration with old one
    if newconfig != config:
        logger.info("Configuration changed")
        config.update(newconfig)
        logger.info("New configuration loaded")
    else:
        logger.info("Configuration unchanged")

def main():
    # Read configuration file
    with open("odr-fab.json") as f:
        config = json.load(f)
    # Setup logging
    logging.basicConfig(filename=config["log_file"], level=logging.INFO, format=FORMAT)
    logger.info("Start logging")
    # Setup signal handler
    signal.signal(signal.SIGHUP, reconfigure)
    # Create thread pools - one pool per configured system
#    thread_pools = {}
#    for system in config["systems"]:
#        thread_pools[system] = ThreadPoolExecutor(max_workers=config["max_workers"])
    config_fetch(config["systems"][0])
    logger.info("Stop logging")

if __name__ == "__main__":
    main()
