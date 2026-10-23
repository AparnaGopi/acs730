# Lab 4

Instructions for this section will be provided in class and on Blackboard when we reach it.

Put your work for Lab 4 in this folder.

## Image Size Comparison

| Image | Size |
|--------|--------|
| naive | 1.15 GB |
| slim | 130 MB |

Reduction: approximately 89%

## Questions

### 1. What reduced the image size?

The largest reduction came from switching from a full Python image to
python:3.12-slim-bookworm. Additional savings came from using
--no-cache-dir during pip install and excluding unnecessary files with
.dockerignore.

### 2. Why run as appuser instead of root?

Running as a non-root user follows the principle of least privilege.
If the application is compromised, the attacker has limited permissions
inside the container.

### 3. Why is Docker layer caching useful?

Docker reuses unchanged layers during rebuilds. Since requirements.txt
did not change, the dependency installation layer was reused, making
subsequent builds much faster.



## CI Timings

### Runs Used

- Baseline: https://github.com/AparnaGopi/acs730/actions/runs/39895124482
- Cache miss: https://github.com/AparnaGopi/acs730/actions/runs/39899556180
- Cache hit: https://github.com/AparnaGopi/acs730/actions/runs/39899857215
### Timing Measurements

| Task | Baseline | Cache Miss | Cache Hit | Worth It? |
|------|----------|------------|-----------|-----------|
| pip install / test job | 9s | 11s | 10s | No |
| docker build | 37s | 30s | 23s | Yes |
| whole workflow | 61s | 56s | 47s | Yes |


