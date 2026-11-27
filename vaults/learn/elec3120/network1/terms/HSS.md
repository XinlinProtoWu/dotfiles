# HSS — Home Subscriber Server (and IMSI, SIM)

**What it is.** The database in your **home** cellular network that stores your
identity and service profile, and — crucially for mobility — **where you
currently are**.

**IMSI** (*International Mobile Subscriber Identity*) is your permanent global
identity. It lives on the **SIM** (*Subscriber Identity Module*) card.

**Why it matters.** Mobility needs two separate namespaces:

| Namespace | Constant or changing? | Meaning |
|---|---|---|
| IMSI / SIM | **constant** | *who you are* |
| IP address | **changes** per network | *where you are* |

That split is exactly the [[terms/MAC]]-versus-[[terms/IP]] split, one layer up.
When you roam, the visited network registers your location with your home HSS, so
the home network can forward traffic to you.

**Where it appears:** [[16_Wireless]] Sections 7.5, 7.6

**Related:** [[terms/ISP]] · [[terms/IP]] · [[terms/LTE]]
