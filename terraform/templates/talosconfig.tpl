context: talos-default
contexts:
  talos-default:
    endpoints:
        - ${ ip }
    nodes:
        - ${ name }
    ca: "${ ca }"
    crt: "${ crt }"
    key: "${ key }"