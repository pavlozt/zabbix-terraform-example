#!/usr/bin/env python3
print("id,hostname,ip,comment")
for i in range (200) :
    subnet = i // 256
    mod = i % 256
    print(f"{i},cam-{i}.local,192.168.{subnet}.{mod},Camera{i}")
