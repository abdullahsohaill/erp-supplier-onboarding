# AI-DLC Usage Guide for This ERP Project

## What Was Installed

AI-DLC v1.0.1 was installed from the latest `awslabs/aidlc-workflows` release.

Installed project files:
- `AGENTS.md`: project instruction file containing the core AI-DLC workflow.
- `.aidlc-rule-details/`: detailed workflow rules for Inception, Construction, Operations, and optional extensions.
- `aidlc-docs/`: generated project artifacts and workflow state.

## How The Workflow Is Used

AI-assisted development tools can discover `AGENTS.md` when a new session starts in this project root:

`/Users/abdullahsohail/abdullahsohail/GoSaaS/erp_project`

For future sessions, start your prompt with:

```text
Using AI-DLC, continue the ERP supplier onboarding proposal from the current aidlc-docs state.
```

The assistant should then:
1. Read `aidlc-docs/aidlc-state.md`.
2. Resume from the current review gate.
3. Load previous artifacts before continuing.
4. Use the answered assumptions in markdown files as the proposal baseline, and ask follow-up questions only where the user changes an assumption or the customer requires confirmation.
5. Keep documentation in `aidlc-docs/`.

## What AI-DLC Means Practically

AI-DLC is not just "AI writes code." It is a controlled lifecycle:

- **Inception**: What are we building and why?
- **Construction**: How will it be designed, implemented, tested, and verified?
- **Operations**: How will it be deployed and supported? This is currently a placeholder in the rule set.

For this project, we are currently in **Inception**. The correct outputs are a proposal, functional requirements, technical design, user stories, risks, assumptions, and units of work before any build starts.

## How To Work With The Artifacts

Use these files as the working proposal pack:

- `aidlc-docs/proposal/proposal.md`
- `aidlc-docs/inception/requirements/customer-requirements-analysis.md`
- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/application-design/technical-design.md`
- `aidlc-docs/inception/user-stories/stories.md`
- `aidlc-docs/inception/plans/execution-plan.md`

Use this file to review the answered assumptions:

- `aidlc-docs/inception/requirements/requirement-verification-questions.md`

## Recommended Working Rhythm

1. Review the generated proposal and requirements.
2. Review the answered assumptions file and mark any answer that should change.
3. Ask the assistant: `Using AI-DLC, finalize the proposal pack based on my reviewed assumptions.`
4. Review final proposal with the customer.
5. Ask the assistant to begin Construction only after the proposal/design is accepted.

## Sources Used

- AI-DLC workflow: https://github.com/awslabs/aidlc-workflows
- AWS AI-DLC methodology blog attached in the workspace.
- Oracle supplier REST API documentation: https://docs.oracle.com/en/cloud/saas/procurement/
- Oracle ORDS documentation: https://www.oracle.com/database/technologies/appdev/rest.html
- Oracle Visual Builder service connections documentation: https://docs.oracle.com/en/cloud/paas/visual-builder/
