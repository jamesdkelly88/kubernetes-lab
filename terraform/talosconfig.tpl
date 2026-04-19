context: talos-default
contexts:
  talos-default:
    endpoints:
        - ${ ip }
    ca: "${ ca }"
    crt: "${ crt }"
    key: "${ key }"