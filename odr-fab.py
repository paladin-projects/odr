from fabric import Connection
import json
from pprint import pprint

commands = [
        "showsys -d",
        "showversion -b -a",
        "showpd -c",
        "showcage -all",
        "showport",
        "showport -c",
        "showcpg -r",
        "showcpg -sdg"
        ]

def main():
    with open("odr-fab.json") as f:
        config = json.load(f)
    with Connection(host=config["host"], user=config["user"], connect_kwargs={"password": config["password"]}) as conn:
        for i in commands:
            print("----- ", i, " -----")
            result = conn.run(i)
            print()

if __name__ == "__main__":
    main()
