# Sportsbook Mode — planned documentary stage

This stage exists to make an important distinction explicit:

- in a simulated casino-style lab, software may generate the outcome according to the game's rules;
- in sports betting, the real-world match outcome is external to the betting application.

The educational Flutter implementation will therefore separate:

1. **external match result input** — a developer-only simulator representing an external sports data feed;
2. **market pricing** — illustrative fixed odds configured inside BET LAB;
3. **bet placement** — fake-credit stake and team selection;
4. **settlement** — payout calculation after the external result is received;
5. **developer audit view** — implied probability and total implied probability for the illustrative market.

The purpose is not to reproduce a production sportsbook. It is to demonstrate that the real match can be genuine and external while the product that prices, presents, accepts, updates, and settles the wager is still software.

All credits remain fake. No real sportsbook API, money movement, account system, or real-time sports feed will be connected.
