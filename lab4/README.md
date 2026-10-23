# Lab 4
## Build and Run

### Build the Docker Image

```bash
docker build -t acs730-lab4:slim .
```

### Run the Container

```bash
docker run -d --name lab4 -p 8000:8000 acs730-lab4:slim
```

### Verify the Application

```bash
curl http://localhost:8000/healthz
```

Expected output:

```json
{"status":"ok","version":"dev"}
```


Instructions for this section will be provided in class and on Blackboard when we reach it.

Put your work for Lab 4 in this folder.

## Image Size Comparison

| Image | Size |
|--------|--------|
| naive | 1.15 GB |
| slim | 130 MB |

Reduction: approximately 89%

### Layer Analysis

The largest reduction came from switching from `python:latest` to `python:3.12-slim-bookworm`. Most of the saved space came from the smaller base image layer rather than the application code itself.

The dependency layer was cached in the optimized Dockerfile because `requirements.txt` is copied before `app.py`. During rebuilds after a code-only change, Docker printed `CACHED` for the dependency installation layer and did not reinstall packages.

The `.dockerignore` file excluded `.git`, `.github`, screenshots, Markdown files, Python cache files, and other unnecessary content from the build context, reducing the amount of data sent to Docker during builds.

---
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
## Cache Analysis

**pip cache:** Not worth it for this project. The cache was restored successfully, but the test job improved only slightly from about 9-11 seconds to 10 seconds.

**Docker layer cache:** Worth it. Docker build time improved from 37 seconds in the baseline run to 23 seconds in the cache-hit run because cached layers were reused.

## Cache Evidence

The cache-hit run contained:
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


### Cache Evidence

The cache-hit run contained:

```text
Cache hit for: setup-python-Linux-x64...
Cache restored successfully
Cache restored from key: setup-python-Linux-x64...
Cache hit occurred on the primary key, not saving cache.
```

---

## Why GHCR Uses SHA Tags

The image is tagged using the commit SHA instead of `latest` so that each image can be traced to a specific version of the source code. A SHA tag always refers to exactly one commit, while `latest` changes over time and does not clearly identify which application version is running.

---

## Why These Reusable Components Fit

### Composite Action (python-deps)

The Python dependency setup consists of several small steps that must run on the same runner as the test job. A composite action is appropriate because it groups reusable setup logic while remaining part of the existing job.

### Reusable Workflow (docker-build)

Building and publishing the Docker image is a complete CI workflow with its own permissions, outputs, and execution environment. A reusable workflow is appropriate because it packages an entire job that can be called from other workflows and safely manages permissions such as `packages: write`.

---

## GitHub Actions vs AWS-Native Services

GitHub Actions was the most practical solution for this lab because it integrates directly with the GitHub repository and uses the automatically generated `GITHUB_TOKEN` for authentication.

The AWS-native equivalent would be:

- CodePipeline for workflow orchestration
- CodeBuild for build runners
- Amazon ECR instead of GHCR for container storage

GitHub Actions requires minimal setup and no AWS IAM configuration. In the AWS Academy environment, IAM permissions are restricted, making it difficult to create and manage the permissions required for a complete CodePipeline and CodeBuild implementation. For this lab, GitHub Actions is the recommended approach because it works within the available permissions and is easier to maintain.

---

## Experiments

### Experiment 1: Invert Layer Order

**Prediction:** Moving `COPY app.py` before dependency installation would force dependencies to be reinstalled whenever application code changed.

**Result:** Rebuilding after a code change took longer because Docker could not reuse the dependency layer cache.

**Explanation:** Docker rebuilds all layers after an invalidated layer. Placing application code before dependency installation causes code changes to invalidate the dependency installation layer.

### Experiment 2: Remove .dockerignore

**Prediction:** The build context would increase because unnecessary files would be sent to Docker.

**Result:** Additional files such as Git metadata and screenshots became part of the build context.

**Explanation:** Without `.dockerignore`, Docker sends all files in the build directory to the daemon, increasing build context size and potentially increasing build time.

---

## Evidence

The following evidence files are included under `lab4/evidence/`:

- image-sizes.png
- ci-graph.png
- ghcr-package.png
- required-check.png
