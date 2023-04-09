# Gitleaks

## Gitleaks Setup
* `gitleaks` install
    ```bash
    # source
    git clone https://github.com/zricethezav/gitleaks.git
    cd gitleaks
    make build
    sudo chown root:root /usr/local/bin/gitleaks
    sudo mv gitleaks /usr/local/bin/

    # brew
    brew install gitleaks
    ```
* pre-commit
    ```bash
    # pip
    pip install pre-commit

    # brew
    brew install pre-commit

    # install .pre-commit-config.yaml
    pre-commit install                  # install/uninstall

    # test
    λ pre-commit run --all-files
    [INFO] Initializing environment for https://github.com/zricethezav/gitleaks.
    [INFO] Installing environment for https://github.com/zricethezav/gitleaks.
    [INFO] Once installed this environment will be reused.
    [INFO] This may take a few minutes...
    Detect hardcoded secrets.................................................Passed
    ```

## Gitleaks Usage
### Blue Team
* `git commit`
    ```bash
    # commit a secret
    SKIP=gitleaks git commit -m "skip gitleaks check"

    # don't commit a secret
    git commit -m "this commit contains a secret"
    ```
* `gitleaks detect`
  * Local Scan
    ```bash
    # export environment variables
    export GITLEAKS_CONFIG=$(pwd)/gitleaks.toml
    export GITLEAKS_REPORT=$(pwd)/gitleaks_report.json

    # run verbose scan with creds redacted...
    gitleaks detect --redact -v

    # ... and generate report
    gitleaks detect --redact -v -r $GITLEAKS_REPORT

    # scan local directories ignoring git logs
    gitleaks detect --redact -v --no-git
    gitleaks detect --redact -v --no-git -r $GITLEAKS_REPORT
    ```
