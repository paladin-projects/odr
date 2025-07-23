from fabric import Connection, task
import json
import sys
import logging
from pprint import pprint

logger = logging.getLogger("odr-fab")
FORMAT = "%(asctime)s %(name)s %(process)d - - %(message)s"

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

@task
def get_config(ctx, filename):
    f = open(filename, "w")
    for i in config_commands:
        result = ctx.run(i, hide=True)
        if result.return_code != 0:
            logger.error(f"Command '{i}' failed with return code {result.return_code}", file=sys.stderr)
            logger.error(result.stderr, file=sys.stderr)
        else:
            f.write("-----", i, "-----")
            f.write(result.stdout)
            f.write()
    f.close

def main():
    with open("odr-fab.json") as f:
        config = json.load(f)
    logging.basicConfig(filename=config["log_file"], level=logging.INFO, format=FORMAT)
    logger.info("Start logging")
    with Connection(host=config["host"], user=config["user"], connect_kwargs={"password": config["password"]}) as conn:
        try:
            result = conn.open()
            logger.info(f"Connection result: {result}")
        except:
            logger.error(f"Cannot connect to {conn.host}")
            print(f"Cannot connect to {conn.host}")
            exit(1)
        logger.info(f"Connected to {config['host']}")
        get_config(conn, "config.out")
    logger.info("Stop logging")

if __name__ == "__main__":
    main()
