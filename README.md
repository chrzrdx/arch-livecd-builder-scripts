run :
```
    grep -v "#" packages.install | sort -ur | tee packages.x86_64
```

followed by :
```
    ./build.sh -v
```
