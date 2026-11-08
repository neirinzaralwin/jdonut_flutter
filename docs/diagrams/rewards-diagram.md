# Rewards (Task 3)

```mermaid
flowchart TD
  Seed[assets/seed/member.json] -->|SeedService v4| DB[(Drift: members, challenges)]
  DB --> MR[memberProvider stream]
  DB --> RR[RewardsRepositoryImpl.watchChallenges tab]
  RR --> CP[challengesProvider family]
  Tab[SelectedChallengeTab notifier] --> Page
  MR --> Page[RewardsPage]
  CP --> Page
  Page --> Ladder[TierLadder]
  Page --> Ring[PointsRing + PointsRingPainter]
  Page --> Tabs[ChallengeTabs sliding pill]
  Page --> List[ChallengeList staggered]
  List --> Card[ChallengeCard: ChallengeArt + EarnButton]
```

Entrance: one controller (`AppDurations.rewardsEntrance`) drives every slot in `AppStagger` (ladder, line, ring, badge, tabs). Replays when the tab turns visible (`TickerMode`).
