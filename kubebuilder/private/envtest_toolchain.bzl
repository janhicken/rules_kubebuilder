"Setup envtest repositories and rules"

load("@aspect_bazel_lib//lib:repo_utils.bzl", "repo_utils")

# Platform names follow the platform naming convention in @aspect_bazel_lib//lib:repo_utils.bzl
ENVTEST_PLATFORMS = {
    "darwin_amd64": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
    ),
    "darwin_arm64": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
    ),
    "linux_amd64": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    ),
    "linux_arm64": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
    ),
    "linux_ppc64le": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:ppc",
        ],
    ),
    "linux_s390x": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
    ),
    "windows_amd64": struct(
        compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
    ),
}

DEFAULT_ENVTEST_VERSION = "1.30.0"

ENVTEST_VERSIONS = {
    "1.23.5": {
        "darwin_amd64": "sha512-ClTe9d7paYZmlOOEAPPa7gUtxh/NuKk6QCqVfp2OKX2TSoLqKpbegMTmpZhYr8etV3pu68QiZ1kzvHYyQ0staQ==",
        "darwin_arm64": "sha512-y0BmbNg9i79GTvmYNdNT180CYiwp/LL9u7y4iAu+ArNb+xBmf7jp3G4AvEq1ByfmzhSGsemEQoZfna68nrWM1g==",
        "linux_amd64": "sha512-nJ70CCh3VYwozAuPW+9/INu2J0mGWuU5cTXfXBhdFdWcuxOwcIE+J2Hp3kWylpCWeIVncBSK9e5VpF1BMkbETg==",
        "linux_arm64": "sha512-RxvAbnrxaMNMBmc9bOUBjrQ9e7OKNL9QAB5ptOlH1bY1CuaIhwKJhf0lZuat/chje0uXQG6ofK8M3F+iioMrWQ==",
        "linux_ppc64le": "sha512-vx47dqHKLMYCxH0s1uUXJo0o9U70+rRXk4rqxqD3IVAzQTcd3uwU8YaHC+T9FqqhddeAgUWJp5N3rRZe8PjG4Q==",
        "linux_s390x": "sha512-9mjZcufVcVuDFMmYBOM85RNBHEHvcLMN8UX6EMFQni8rVJOpnd3WO+ukufPCa4OJ4Dx0xGlEB3/esitteFlY9g==",
        "windows_amd64": "sha512-1pBYs9xMeFwsLGp6ZQyQl1EVCnaej2cgd09MsGRaEgBk0bQZ7c1DQG38p2QdUe8Y/W9JwSP8cOzG9U9WmmUdeQ==",
    },
    "1.24.1": {
        "darwin_amd64": "sha512-0AwKisRdPAutEpSs49hQJoHYTkjH26+3+Ak3HI0uUXF0/Fv3uiPNCysJZYNavpr8J7YXJf/ukMzmEZCT8UKOcw==",
        "darwin_arm64": "sha512-+h38L9blOGn1WICqnrjcRSgVWd6jEHmrbovWpVrQ4ThHfV53ZirK9O2QVDIj4fp/aZ5gek6hMl9+0Yfu2nBH+A==",
        "linux_amd64": "sha512-v5mod0dDDHNp/P5jY4+aEMO2pFgc/pPexf3VgDbicDYLSLzOuh3FeyQ5upydUNwzAShzcTaJOg7Ztnur2C8wkA==",
        "linux_arm64": "sha512-9lTtoGP6IWIwRgZkq5NN2z8mgWVlvD/3ii/mrXkaeExPpbCXZE4iFesI0p/IS3rfa9Pojx2GjxzCOc4u/4wfqg==",
        "linux_ppc64le": "sha512-VnB1t9QIJlOervNrTeeOsrMAdjTSklvs9hRGUbD7fVI9EW87Cj/GRKcuE9RyQQ1rmlo28DBOBp1TcJU3wgPbNQ==",
        "linux_s390x": "sha512-VcKQoR4MxyWbtMSJB4H7l8fjGuNccn3qZAMzXR33+RBLT3ZfXD3XIaEDk1FZKLWXHqWjECR64EJG21YQIbDihw==",
        "windows_amd64": "sha512-AHSirmNNmmvA6CgkccWQiwRp9dV4ZyyZ6JEHzENqThFz50f/a1AAFu9BrOsoFbdBVvHQxOLlrLeeB2FMXDyGAA==",
    },
    "1.24.2": {
        "darwin_amd64": "sha512-jQpzMI2q+7Ze2XRJvOgeCdJJBF1FlM5OQFDMjF8qoxR79KT72mtzoYsKDLpPiKAaTgufZsNx66kk47s2/phg1Q==",
        "darwin_arm64": "sha512-8utXrAeg7rl9ao42vDl+sLW8qkMsyttaV01WhN1ILSEhoZPz398e4EtN983q2NiZxaV+dTKD6kBrrVYAY9urtw==",
        "linux_amd64": "sha512-KzMMGAL3/YWKim6XFBsHpCYO7BNXEsiRPTa7jkj42/pFqOWxPBXnwgEnpV11v9pQB78BjoU88VbjrCsBnUkokg==",
        "linux_arm64": "sha512-XNobofc0oGfouCMTD8qca+wVEQaqHTKFbvdSSv391zPmxch7G41BwpMIP9ZKxmjbi3TcomVU4MmeASDm+Z+eIQ==",
        "linux_ppc64le": "sha512-wrcvPb3aJoqtuGw6vnivQSx0p1C2UrXDJsq2sGqO3pwvV9+tFsnm/dxoxWIoqwphudoBMbU/TearzUZfJy6vCw==",
        "linux_s390x": "sha512-HcP0tzdf23A8HdhOMCVZxyRcBnYlDib3OWrRRfFBYol8MngSp+QzazsjOzKTOLWNM0DyiEkJGMJYg/HC3waJrQ==",
        "windows_amd64": "sha512-uXCAAuYmXrcu47qKIpYk27EyiIHwjlOFWy0i+zNNa0CvPeEblZjzpMaCm7tseHqkVWR5hVNU7aHomd80ouk6XA==",
    },
    "1.25.0": {
        "darwin_amd64": "sha512-ghPvGxYMzsuAz2czS2gthIhjZcKg+YZKF5VtfFaoJESXNkJUzuV6gePOaXo/7usNJ8VRkdy6xU76b5qLSHaczg==",
        "darwin_arm64": "sha512-DuWrohC7BgdF+CxIrZvKbhZqnutoRQGpefo69qdUNe4cTHj4UZZHJOsrEdp5Z9TqfSm+KnxL34UCN9bYgc+i0w==",
        "linux_amd64": "sha512-XKVhcpini5WAeO8Qjvw4u3Mpe1PAE1N8xxjqX8D0DjTMz3T7DSgasQacjP0nG3zsHc13/343GiuYvk77akmF8Q==",
        "linux_arm64": "sha512-LHQ84Us8/y22UdvwCRA9WlPamJDmpv7DvLrwHEFQF9Ka0+LGdnl6rSmRUiqaGy73Jlb5qbOS8o9Iks4P8/maCA==",
        "linux_ppc64le": "sha512-3krfD9LYBmZ8E/Mp6HdRh7u2mycXxGL7i4YDAWElh9gzApoAfm3yUGIGMPOff63LWn/bym2dxPzGgFfpZUtdeg==",
        "linux_s390x": "sha512-qjQ1j/l+YiULIPvA38Rle8e4qGjZIv/UkkQYQ3DMsh/xRJySRRwpgfo4g/nWQeYc6jxmrC4As8vo4uHKjRpiLg==",
        "windows_amd64": "sha512-0vTEqv7+9p+WRgXbuVHwod1XQKIHcOKs4xEcuMmNrz1y8F6i1TwVSfdS5UwNfQL1VdZwFta8ZmJxp9si8hIMCA==",
    },
    "1.26.0": {
        "darwin_amd64": "sha512-KTYV2V0SwNpHEjyvg4m8wbHXrjIhwjuYvSa5qhDVYIzJx/jVwjo3bL4TaDqxHjAUK678vI+9gWfz+mFdrL9DUA==",
        "darwin_arm64": "sha512-m5dRgN+lD1YuPmMSXQd1KDWGcK86HgntoS7dbPKdjGprHv3MuwciLRjjIBT3pQqcnWbAUDUKM4EVqmW9N9hPQQ==",
        "linux_amd64": "sha512-EVJ1pGHl+wlRX02HoSsHzN8WYu15qJrwheyWWvGi6d1d3PqTmdoMQJ3im38q7eKdmvbLke64C+u+sJ3Fapqzbw==",
        "linux_arm64": "sha512-dwOopQcr+HRENgNudEy5P3nZHUnT3ltAfN1Z7kmJSjRhoe6xv0/nr8SyotUFxiwFjVQQ/alc+Toab6uP0zqGhw==",
        "linux_ppc64le": "sha512-ghljETZQnIYvJaXhLXaDFdjw17jsOzWWDEfApSDOJGGTJwEVbhwdqgFKbyYWHiVmk3xT77SkKpoyQO4+0+NcmA==",
        "linux_s390x": "sha512-Xrw9GvpzYaONM1BQbyOumsolpr76iPV+zMHkhXhbhkNSh82m+1Fg0m8+qBLAGKhZQ40rxc1lDUqa9G+XoSa2bQ==",
        "windows_amd64": "sha512-uA8ztcUKgFeJBxZOSCWv7r74N0RHDjnmAFs11WQx3oA6eE2Qj3nyK+2A3gkikyrFEhw73G1n8oPAPLdBty1ndg==",
    },
    "1.26.1": {
        "darwin_amd64": "sha512-xB/50DdjxcCM6HmiBIDZqSVKnn9YEFbPXOz2UhhF8XHgzhfsPOI2lp6eDEzseS3C2bKv1x9mE97RkpiPHhYrgQ==",
        "darwin_arm64": "sha512-4WCmyGO2LDAVgrZjXZ2+pCdQJWOfWJWxH8YbEamYbUAc9WaVro92ANwXxapZAMkNr7XJAPtxZicUWJSO7W32jw==",
        "linux_amd64": "sha512-nds+FydZvmSwdIwNEDqXbf1q7NyqDI//dySom3Qms+AIY7h4Kz3/FvBHaL6eVqy9o3VefHwAVxvDqNEAsl4EsQ==",
        "linux_arm64": "sha512-mI81tojFDOSQVtdUnwUyUjlztefjYpYxzadPLnx603Fc+450bOSOmzZqqtV6wdGR+XNeWeSRmGuy1Q74UAG+1A==",
        "linux_ppc64le": "sha512-vyFsu3v+RTwG1VxNDcqXZb3t5UhezNZ/uHoheNQasvmgS+nmxXsAMcP6cbjjRJB5e09xprvNXDJHkcFH/9D8Uw==",
        "linux_s390x": "sha512-ybTIM2AK7H9ZI2kL1HTt3N5151RG5jJLDIAKWwiUE880Asx/ctIVTbvdsAseRZcgQucXr1oxRzvKsS8HJEbDRA==",
        "windows_amd64": "sha512-oTlOrgOw7drwTQhILYI6f1B9tnyp7X3XdcaVNFfNER9wQgGaD7vAf8uMUuw4BJM6DG2GQ8gzb9jWagY/p6Q9iQ==",
    },
    "1.27.1": {
        "darwin_amd64": "sha512-ZjmWupVZTC7pe2PkNWhWfUi62LsEWYvCfiPwpkplJdZzvEA4F6e9TfsEP3/rf58x54fnESMYfjU0TMsXF5uSFQ==",
        "darwin_arm64": "sha512-reo9s6ohdHQyUaYYTPrQt0IkBz5hjxnf2AxNAxwTUqGIENZSpcQrEOE9jbheQGedroNEgjjCLu/wS1qs1lMAEQ==",
        "linux_amd64": "sha512-YH/8MVWDplSnzm2e4bwM4YuoV1ChP32XLv/iU6U+O7mRD1+wg+uv14AtORkiJkkwE7nIgQjO6qqBkjIwmc96ng==",
        "linux_arm64": "sha512-RQVoTeFuVW/qA+oqnGC9VD3SY7PQfla/ojkfCaBe23xl2jxFROHWtrFLBbntmR34g4XlmRE5liCum2YNVvSoSA==",
        "linux_ppc64le": "sha512-vw+CWJeUADBLx70g91W76GAkDt0PBZtayoQA0mpFt9OqCy83Frz+B/7dM9ljctgebkVjpPlgx8HQkN1LOXMNuw==",
        "linux_s390x": "sha512-/OY+sP8/RACT9XLq4Q06lyE85xO4GrjcwdxZtrYtcsSW+/UcjSYhpSOPGv6n8z8eQZ6jDsloHRXPzb0kwtNnTQ==",
        "windows_amd64": "sha512-qLzUWG7R2U2nRYj5Cdedq4F8xynuAf9Jk2LRGiwDVeBlvzrh0cgBA1orR5ILDaskx5WZG35AF1Es9YojbvSW/g==",
    },
    "1.28.0": {
        "darwin_amd64": "sha512-9MWuOOEzHDK0FsR1Nqo9NeWLm5s4ALXg9G7ISVtOyJHcyZNm3ZqkT4t66yQmnxF/2GcgJ5AnBtiFsb6xq9x3HA==",
        "darwin_arm64": "sha512-DfOdAeV/gXXoboQ/wddd9AKKKIn+t0d9ZSIMEgwEottRGxxKQwPVse80rQwXM8HeF6ZFAomMliWyo1vMoT15eQ==",
        "linux_amd64": "sha512-AAya3CwUC+0/c+KMqr36gtdtfDXEsM+TMi0Py8HyigcJYukoyRMuprYMAu1nenRJz6sLkRNJcUGaIdq2XOV4Hg==",
        "linux_arm64": "sha512-Smi8bsIMY9szD3Y780e795HTNfooYd5rmonPgTK71TgElJUFXgxHd52Kpod+LNt82gEGRgn1W+Ol3/FE9IzwhA==",
        "linux_ppc64le": "sha512-X9At/KfnTPXHUsTU8xAFqDFsRpBIWATjjhDtinvBosY42fS88VaM/n4ZrhTM0qpiaE5sVkrMkCTcdN8oBwsZrg==",
        "linux_s390x": "sha512-T9239itrB71NOV85leDToweI+kCQZK0j2DcTMrZHpoHowQBC+Y8C6Vs0Tlv4xuARBv7r+WjCDeQu3bMIMqjHjQ==",
        "windows_amd64": "sha512-z4D9oUo9fIq04VZaYkPlNUbA5StzRMNCKWSV/FN7UJT00V6ScZikORJ/g1K/a0P2qKALIXxXVrxAVwXswVT1gQ==",
    },
    "1.28.3": {
        "darwin_amd64": "sha512-gY/w+RSTON9sFeQuy4iyR0Wj80CpidinC148lwahLBm0p96HP+t3gCBmXdeXXsm+3beqXpxg3KN4KWIlO1eh2w==",
        "darwin_arm64": "sha512-65rqK23RlrhNi+12uw2otMjp8R3Zbl1yJOvbOmP2GkzOr+IXdMeOVV/DsyUF55c+HPP6nocQNUbgiPfoYSjFxg==",
        "linux_amd64": "sha512-23qvrfo8HLXHvYLzdUJbEdZlISlYCsUHsuLikMEBjvGHNzUtUGkDUDodR8wVafBQ3/cboi8GBX96KuMYr9n05Q==",
        "linux_arm64": "sha512-pbmUXVsgnGjPiLj19Lqs3XWdWwlTa0sFNXpmu4XubaJFvRrxZztHkHXH6wtGBBrxquKgfO+qX8/l9V3+CZhPlg==",
        "linux_ppc64le": "sha512-wzMuMzYcMz7Gz1JZWa0muNhUtoWXFAILBopDQEJ+uciBF4JYV4CMuzHcCUwPritHgwQnxs1rO+nVDoZM/tq6sA==",
        "linux_s390x": "sha512-MtwBcURPdi73RtCbcizUIdVtpRQZEZevWdhncoHNeqk3HPyV8viXgaqJ6rln3ZQF6J7Nw/9pvWGxY2ZDOHC9VA==",
        "windows_amd64": "sha512-jr4o3qu91jVHf+yLLTE9xNTpqHG/2/NmFNNX3EiD00Uj+bfkwh3fZlqq1bmdn99ftk6zyvUuZ2s3ILRewCMCiw==",
    },
    "1.29.0": {
        "darwin_amd64": "sha512-4YYHkklgohrXLMdqCvHdB/AntWROJylWSJpuEsfjvLeJp5ESeRVzPM+hfNGk8bfLgZLVckS0KkDKn4pdzpi8MQ==",
        "darwin_arm64": "sha512-J8rI6m/71P9iUZVpeoOs93OmtvC6du9dSvRS864c6Ubx01lEeAweE0C+GeHP7pqUjIyQAnisFxLbQqo9cGO7Sg==",
        "linux_amd64": "sha512-JWAgq4TubY1VvXol9qu/7v663g2NF818PRw7CKm0hZRU6X9JctroujE4ikxwxcwIKMT/kTCNdtZShqWSWG+/lg==",
        "linux_arm64": "sha512-8QQVUSBaXStVzqSps8auAN5VQ4m6/Yc1GsiRzy8BpIzB8YAzvbg+a09zvCSaIIGGjMn4wfJiQFh804hfHz7Mwg==",
        "linux_ppc64le": "sha512-ZBoYh8Ra3eGE/KnNpE5j6lkoFSoKoQEHE96O3YA04vCSMA1FfbDQRW/ONvJ7KQRAgBglRomZjkwLffY3UqPtUg==",
        "linux_s390x": "sha512-hXcPOdDir3T+lfHkUhdp7r6AYPvmBc1OTfaJuDttPVzJkD8CXGQ+SsP6w3Uo6Q8OTakfP6h5wg6BHzXxbOjiWQ==",
        "windows_amd64": "sha512-/YKodvJ6myiIMV6UxG2hcEo9nx68oU3z3qsJ7t5yFMF6c115X9Li6vYqbW7GxEov/C071apbGIicYfvGTfnR+Q==",
    },
    "1.29.1": {
        "darwin_amd64": "sha512-xsUGXu9CAjmCMoj+nXGm/s85hzcUnvMrOLpkmysA6/atJmDb0x+SvZKSXLgqk6zHRk4P8DNU9g+4/rKiBAZolQ==",
        "darwin_arm64": "sha512-QCAp3F4VuQM+YEZFcmmqyEX5i4AdrHlZ1eA5DunvlcgiUJT38vPpZm+iv4vsp1mAAwI3ODYUCINlv36oAGgz8w==",
        "linux_amd64": "sha512-7m0BnT8CCd6ixYcVCBN7upuNPe5+ooen3N+lIKyp3mL+Je026b1pPiYzuGrck5RLNFJNJobpos/g4xWasE4vzA==",
        "linux_arm64": "sha512-ekrqSaaWQEZilWAP8tDmbZ9PcgqCR6pj6oTI/B/eojEmU7Sukr9TPlF4PMf7GHDaeGiaLvh0cRaoO9St2h18Eg==",
        "linux_ppc64le": "sha512-D+tsotiGv568kXuMxboCMwctktIg0zXo8aDMjXTR0VkeVd+/xgWpqmPQJ6AdjMXRqGABDPf+HZ2Eb3hotCE1UA==",
        "linux_s390x": "sha512-4295gsDmUHwv7sc31mh1/Q2qleQmPyL3MR4HspyVP4nxksqN2vagvCLIjtOERAEvWQ1qhOjQETjJeoaRb0185g==",
        "windows_amd64": "sha512-xbZc7oUNy3DqLs6km3QR47g/ZApU6izmwCnCK4AuCD++/ZKYmjN3kXIzp9UVfcb8y78ZFs6ACFFWQcMvLJUwxQ==",
    },
    "1.29.3": {
        "darwin_amd64": "sha512-VmFNUuU0UgsDJXxMVJd+bs5fEt7BNcPkaYN9wG8P8CYgj+Fy0F6bjYZdqkzcAzwshfPX9UfgssOFx0CYlu2bFA==",
        "darwin_arm64": "sha512-5ccgmAUAkV5yD/c7KNi1qWnyaAMNC3+fMCQzfYUpFgrBzj90DmLzftd4QgcBxV8QBqhwU75jn9XzB6KbDp/0ZQ==",
        "linux_amd64": "sha512-aSZ/dlMFQ2MGIhq79jWXwzg64i+4uJPsXbKLEuAM8KaQI26QOMwztHXUbOLJrBLK6HFELaw+ySsMWMIfwNjBuw==",
        "linux_arm64": "sha512-oaRuy/MQSVenTy7VffWgM1MMwBI7G4kzUND8q8JTnuiEcprS87vCFs+x/L3sEaL8sjmgoEq709cSuYxGKH83ow==",
        "linux_ppc64le": "sha512-h/1lc/SiLldkAlxMOZyrG1xvM45OvOFxmQlc1GQUDB3bZZ/BUlG+9hLzOKDqK+/CjoFqiRUB/SYt5A6hZdSppQ==",
        "linux_s390x": "sha512-cvvnM6J1jeetRplNYACMSen4R5bu0jAXkmLKHZG24pMgaafMiy+p3aaE+99z5oJb9eWWD0cGwAmqUDSAZJSH5w==",
        "windows_amd64": "sha512-Q2frvxgR4Df16FZ0NSNVlxeICYG/wuKiOvpUZlR0vHxKWjb2+MdvuM5pXlSIYFWlew0+j5BziTsvJGpWIytE5A==",
    },
    "1.29.4": {
        "darwin_amd64": "sha512-ljGZDzzV1QIPgH4TY5uqvM2CBRYERzt6W/wUPckgfkwy9vZL5GiT8H0HI81RnDhJlWPcDvRCx4l1M0cPVZ2ANg==",
        "darwin_arm64": "sha512-1GwkBw+YMImgLLHF8b+kLEzMW4UJ5y97rFDXpLRf6i9xEdtWnWWBNzYmZ/8mqItJvG+tHbwQgzQubWQodspquw==",
        "linux_amd64": "sha512-rG8P0E0J4GoxeG2/gokfbbRZ54fxLMy2aHBKrRgymvfBp7w7xcSwfE+ln7gxD6weHbEX58Bz3lnY9E+X4vvL+g==",
        "linux_arm64": "sha512-wRUhVxhyQaIH2vxeil262SMWsFMzGaJCXB21/yqKKYgwFEDZVSZdYhreJJxMugNJqJRMjsPomk8SgTV168JJ9A==",
        "linux_ppc64le": "sha512-bPL4CrwnqOZTagXLHgUdGO4aRmLY4C3K1zuHmBYqqzzaBP4IqqhP4xIATgPeOJp5FIsguggNIIPK+0twi5Izmw==",
        "linux_s390x": "sha512-Zmb5+QZGCws4azIn+ApZz5L2N3wS5wIwSBf677IdBOrvYgRzi+oT3irGtEYsFxe33pJ3Vd4nD8IpcwTP73+o5g==",
        "windows_amd64": "sha512-pWcpyWj+RioAK0r+BB+HAJAIU8EU1KZD6d2y4s7feG69WgIgNBhyihMEFFtaCJ9mkxIEVq9OeLfQpdcKm0xYow==",
    },
    "1.29.5": {
        "darwin_amd64": "sha512-er6vXA8cK2+iq4/w/9jrG9HbY4JD+o8hg8udvehHRMXouk3WY2tT0SEMbocx3ClBn86xEI+GuHLLPBr6yqKjxA==",
        "darwin_arm64": "sha512-RNMBq65EIbHkQn3kFTtzBaI5IwLf2nkkJjPrDEQCnOYPYHqR2oQSrpbqjvM9X75kLxxacuYMpf+o5gbC7zHwVg==",
        "linux_amd64": "sha512-sRGQud1S5HPOV/eAoUX8biJQeUoqn+1NubSxMEPfQ2pfxmwHfx60gIdhdkBmoZNtonZgxi0Cq1klsmTz98r3tQ==",
        "linux_arm64": "sha512-fLR2pXB2d1+uwe9uomS9O7lUQy2gFmuTyS9ReGm861EzYSG07AUL715aWhyk3789c9Vv2QrMVskMCe0GTrkteg==",
        "linux_ppc64le": "sha512-pjl0IE47u5ERRLlqUg4vEW2GJyebl1Qj2GskM2Jn5H8xMqDznVEFvH1JzSgxwBfqi9ymJGdDg5HA//1I9EaL0w==",
        "linux_s390x": "sha512-BTQMxUTklsftW5APgtP1zxbHgaoAsYfc54eQA4joJRX+Sv+Bj8YD9KH69RTJriYXnfU1Z6j2Ww1/gfTyOQO0zg==",
        "windows_amd64": "sha512-1EDjr2f06l9UWYGvuLqMVpSdCn17FlNHuskTOGc7eQJP9BN/4jNE0NaF7ide/l70Bmui0L+EdCzY4v6Ovv+lXA==",
    },
    "1.30.0": {
        "darwin_amd64": "sha512-5wWzUYkFKICv7+rHJ5eDTSdQv8/Ilx3ZE8wrVXXqciLpz6Prs4peXe7I8GCJ7MZUvq+cT+mQrPQeV3WMJrPWKg==",
        "darwin_arm64": "sha512-SMH6VVXwIfiqNl+qqWsQaATOXjAiFCoqFmvJHs1bItp58BLSDBpJY+AjbfAKIU8zEc3YQt5KsZRCyhyDs7y4WQ==",
        "linux_amd64": "sha512-1Thw4abJs7UDZkiak4f04lTGZJVeky4+JeIIi7Q3snC/q3XSQbUISSM/mjS7Hwi0FWfruB6ik1IQSuD1scueiA==",
        "linux_arm64": "sha512-FAdI76o5RZj1AXXoCc1TiWiB7QRtk+vfvVRCEA9os9jVH9IvjPGuBqbkNHOJe3id8NtuCubEXIMgsADV7pAABQ==",
        "linux_ppc64le": "sha512-BONXA1QAFUfQTv8XZNDa2p9UUf6tVUTn8wRXh0tNFX/GK3aQJvTE/juN76UokrciUyIp4sbCetmMNYx2rQGEJg==",
        "linux_s390x": "sha512-GfLVFrW3dTr9q5kZAeaQzbcoNnt4OzIznL4tE4YZs1weWdEzaLeDprRVsw0ZCr3+t5l8SK4XEPZsabLcN8hDdQ==",
        "windows_amd64": "sha512-vwhGM30vuFuWdq5etHxnbpMVYS3Mui5Px0jWx2vBIoMhz6GCJ06Xc9ZJwimPYk9iJ4AyxUdzYVmoaVsXEt5k0A==",
    },
    "1.30.2": {
        "darwin_amd64": "sha512-v64zF+eqA5E9FDWgjNEQrEYwIkOJI08U8p0f81M3rLcDm/ZCEEHahJw+TMbChH0oXCnD61IY1Okh77Bz60E73A==",
        "darwin_arm64": "sha512-VZy3QPIigl9P0YkzMn1dBXYPD1X5CYzuD8qIgMbeEPZrcea7pYQaff8UOp7SJR4tiQTYivedXX47kB0hwcyMHA==",
        "linux_amd64": "sha512-vo2ntHB1R7fKDZoesZxWh/Ri/vipEvBtan/A5giO4cLmSyP7MwpbTp7zw1AKOwafFmReUBrkdfHpmAWl8w5XAA==",
        "linux_arm64": "sha512-ZIQGkKnXV6D1nwnxptm1TgJddA16HNwzeFpdBfuPXemaQO1shgi7hG09m4A9Tzk/lHTgF0/DleMZBCz/82JoxQ==",
        "linux_ppc64le": "sha512-qkEsGkDOOprGTE5CeMwkhdpICsJnUPNyISE59uk6XJmYWLiGYciDF0C8ChjOPAyjRzNsboHd86yLYMw2ZvJSzw==",
        "linux_s390x": "sha512-IxbO7/0BcMi018iKhustFMAS8vbxdEgFLA6JEVZwaUC5yN+LFosvRlBu/51uzfgHAS3cQwfoxVEXsU+GCjsbpQ==",
        "windows_amd64": "sha512-Ci1kBc1CEb+9q//iFG/Xjfr3Vi73/fXvkQ764gLeyUTyUUBT6Z3Kn5wzUqwgz/YogdzArbXz0iUb8BnEHpYF7w==",
    },
    "1.30.3": {
        "darwin_amd64": "sha512-VjW+tuCKIoMYpD2d8nupKHnIzlU6OW4YMwYyuFtHJLPyxJy0HFUMFimQb1g7szJvl3x0FFcmuHJ8hG0UNj0zcw==",
        "darwin_arm64": "sha512-h47tMBb7xQXKsxC0m+K62y24jqqgL6IcRIwP9ZbVz9KPlNspQyBQ6yfxp6/qcRV+3LT+YUjyjmO/RmirfV2LWw==",
        "linux_amd64": "sha512-DllIUR41FW6KuiY/2HiYOxGq2C0PdLVQepgEudEBWD8cSEKBaQxv8aNnjtA4yHSRVZJ1k3QIS3i1et490SZsHQ==",
        "linux_arm64": "sha512-slxF1HN5IuEjQzRLKCTSaBwAZvkiQtWbucovPRUlPxsOqoj1ZdmPxvyw3yTmeRae0OzcR3gqTiWH3edrGau7DQ==",
        "linux_ppc64le": "sha512-nHEgGW5nrAT08krCfvrXHSwThGcdcH7+XG5uAgMlMNyLjyREYuHv9SAoelC1E91ys4wsr5ejQDofVs8TyZdWSw==",
        "linux_s390x": "sha512-BkOi7IdcOG6KJSRR9oOS2WbFAnuK94ol9WYNf0NE7YqiXPjYBXRZ67GNA5xJThvjk1kqKXJLFUA148ZUHaPqbg==",
        "windows_amd64": "sha512-qvdWq7TiczXHkVU4ZXYa+BgJe0jGtgLwlsHguFD6m6CrPyNMtIfaP/dkb8mqu1KIJT0CEOuAcb4oSe7ynO0grw==",
    },
    "1.31.0": {
        "darwin_amd64": "sha512-1oGDhgmhsIVucxiI4NsKEZEAPhAhgBtZabfXCEEwB2swstmeU+Rg8cUgKzMINUohGL1KMw0G2XeX7wCd1W4lbg==",
        "darwin_arm64": "sha512-5Cwn4e6Q0T1WGJ5mXUx5t6NPY3WB/H4gsCijwWsiuFBgdg65HKeZAbwcItzQ1m70Gg92DC8a5lJl8FduQQnYfQ==",
        "linux_amd64": "sha512-XZauKEYQhjzll04DCuzS6q1pPzIQEDyneBB6oOoA9vHQp7GzSqdNclfLDX9xPC2jZb66ibHWCCPOVse4S5NUIw==",
        "linux_arm64": "sha512-cvXI/WFcnbYu62bjDt/aDzh5v/o1d8V3bsgzY8AY1/UcF0rF6oB0FAcqIfgVGnvfmCb0FFQ/aQaGVQ5J2yAsoA==",
        "linux_ppc64le": "sha512-N4v1RNWXay+YiE2IRSIA48xgqVHShrUlE2G9sa6aoTbhI1zbBo9Y4uQVPNkh2Kw2XRWk146FDdVweHrIm95GGw==",
        "linux_s390x": "sha512-J5yMA88G9twW0G4BTwX4jr7hu2T1yoh3M26+jbwARXMm0XZfIJNLIL5c4dO4T+tKBAZ1dj/16zYoSIE2Zndhcg==",
        "windows_amd64": "sha512-QwOoElx8w7LWiSQT9x9avB/iSQ+PUAwaK2f449k6oV6lzYkhL7NWr63nkDL2JqZrZ29DPwAn7k7BbzBJ2H4nvw==",
    },
    "1.32.0": {
        "darwin_amd64": "sha512-p4JP+K6cUGK8veJDp6Ohx24C3gyS4rMy2vGVRAWu3thWAj8nfXQZeGLQ1ZCenh3KRRtfLoR5bkUa1gEeyY+EMw==",
        "darwin_arm64": "sha512-coxm75wlA90e2ho5j1egSCmrcDPhAHteI9bMhl6KxadT5JhoR8j1t2s0l65OPkaBIOJexd/jo7GQHT/yC5en+Q==",
        "linux_amd64": "sha512-OpWErzDQQcQok9j3qGCqQ0l21K7kec8umlCp5Wd9zIPTASohRqb+tbLpWns8b2V66cWRdFmBJi2osG5LYdzfFw==",
        "linux_arm64": "sha512-zm5ExaPpm1lROM3jlsGxeQldtHe+jM2fBcvRNbwVw5EADW4UaQeSKHLwGZucE6foq2tUAvjK41IlFPDvZZFAAA==",
        "linux_ppc64le": "sha512-9QZA/MDrTBx5QgBRaj75VCsxuUBHI0tWZ8PR/UZPvfom8Qtk/dxBtVtUZsIPoUGkOwUWT7wE6msq27FkknZxRQ==",
        "linux_s390x": "sha512-BuEGGB7aHfjUlmtRr1lcSNRIhFbh03BSAgpW9WhtCYpMMsfaEiqi65UGBU5oYQgaqOXJJXneYqbGlwblAPf+wg==",
        "windows_amd64": "sha512-uqrvprujXo6rNC0lpFvWQzHMXl1h/Qznixw2EON+wbCcPJ/t0ZUEHwlLvKy9ry4US/tS3DUdw26O+2D0ypyPJA==",
    },
}

def _envtest_toolchains_repo_impl(rctx):
    # Expose a concrete toolchain which is the result of Bazel resolving the toolchain
    # for the execution or target platform.
    # Workaround for https://github.com/bazelbuild/bazel/issues/14009
    defs_bzl = """# @generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:envtest_toolchain.bzl

# Forward all the providers
def _resolved_toolchain_impl(ctx):
    toolchain_info = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"]
    return [
        toolchain_info,
        toolchain_info.default,
        toolchain_info.envtest,
        toolchain_info.template_variables,
    ]

# Copied from java_toolchain_alias
# https://cs.opensource.google/bazel/bazel/+/master:tools/jdk/java_toolchain_alias.bzl
resolved_toolchain = rule(
    implementation = _resolved_toolchain_impl,
    toolchains = ["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"],
    incompatible_use_toolchain_transition = True,
)
"""
    rctx.file("defs.bzl", defs_bzl)

    build = """# @generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:envtest_toolchain.bzl
#
# These can be registered in the workspace file or passed to --extra_toolchains flag.
# By default all these toolchains are registered by the envtest_register_toolchains macro
# so you don't normally need to interact with these targets.

load(":defs.bzl", "resolved_toolchain")

resolved_toolchain(name = "resolved_toolchain", visibility = ["//visibility:public"])

"""

    for [platform, meta] in ENVTEST_PLATFORMS.items():
        build += """
toolchain(
    name = "{platform}_toolchain",
    exec_compatible_with = {compatible_with},
    toolchain = "@{user_repository_name}_{platform}//:envtest_toolchain",
    toolchain_type = "@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain",
)
""".format(
            platform = platform,
            user_repository_name = rctx.attr.user_repository_name,
            compatible_with = meta.compatible_with,
        )

    # Base BUILD file for this repository
    rctx.file("BUILD", build)

envtest_toolchains_repo = repository_rule(
    _envtest_toolchains_repo_impl,
    doc = """Creates a repository with toolchain definitions for all known platforms
     which can be registered or selected.""",
    attrs = {
        "user_repository_name": attr.string(doc = "Base name for toolchains repository"),
    },
)

def _envtest_platform_repo_impl(rctx):
    # https://github.com/kubernetes-sigs/controller-tools/releases/download/envtest-v1.28.0/envtest-v1.28.0-darwin-amd64.tar.gz
    url = "https://github.com/kubernetes-sigs/controller-tools/releases/download/envtest-v{0}/envtest-v{0}-{1}.tar.gz".format(
        rctx.attr.version,
        rctx.attr.platform.replace("_", "-"),
    )

    rctx.download_and_extract(
        url = url,
        integrity = ENVTEST_VERSIONS[rctx.attr.version][rctx.attr.platform],
        stripPrefix = "controller-tools",
    )

    rctx.file("BUILD", """# generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:envtest_toolchain.bzl
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:toolchain.bzl", "envtest_toolchain")
exports_files(
    ["envtest"],
    visibility = ["//visibility:public"],
)
envtest_toolchain(name = "envtest_toolchain", bin_dir = "envtest", visibility = ["//visibility:public"])
""")

envtest_platform_repo = repository_rule(
    implementation = _envtest_platform_repo_impl,
    doc = "Fetch external tools needed for envtest toolchain",
    attrs = {
        "version": attr.string(mandatory = True, values = ENVTEST_VERSIONS.keys()),
        "platform": attr.string(mandatory = True, values = ENVTEST_PLATFORMS.keys()),
    },
)

def _envtest_host_alias_repo(rctx):
    rctx.file(
        "BUILD",
        """# generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:envtest_toolchain.bzl
exports_files(
    ["envtest"],
    visibility = ["//visibility:public"],
)
""",
    )

    rctx.symlink("../{name}_{platform}/envtest".format(
        name = rctx.attr.name,
        platform = repo_utils.platform(rctx),
    ), "envtest")

envtest_host_alias_repo = repository_rule(
    implementation = _envtest_host_alias_repo,
)
