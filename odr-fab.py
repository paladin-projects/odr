from fabric import Connection, task
import json
from pprint import pprint

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

@task
def get_config(ctx):
    for i in config_commands:
        result = ctx.run(i, hide=True)
        if result.return_code != 0:
            print(f"Command '{i}' failed with return code {result.return_code}")
            print(result.stderr)
        else:
            print("-----", i, "-----")
            print(result.stdout)
            print()

def main():
    with open("odr-fab.json") as f:
        config = json.load(f)
    with Connection(host=config["host"], user=config["user"], connect_kwargs={"password": config["password"]}) as conn:
        get_config(conn)

if __name__ == "__main__":
    main()
