# Reflection – Week 2

**Oluwagbade Odimayo**

Week 2 of the DevOps Micro Internship was all about Agentic AI with Claude Code. Across eight assignments I set up Claude Code, built skills and subagents, connected it to GitHub through MCP, added safety hooks and permissions, and gave it persistent memory. Here is what I took away.

## 1. Biggest technical insight I got this week

The biggest thing that clicked for me was least privilege applied to an AI agent. When I built the skills, the `tf-plan` skill had no Write permission, only Read, because a plan should never change anything. The same idea showed up with subagents where the security-auditor and cost-optimizer were both read-only, so they could review my Terraform but never modify it. I used to think the goal was to give an AI as much power as possible. Now I see the opposite is true. You give each tool exactly what it needs and nothing more, and that constraint is what makes it safe to use on real infrastructure.

## 2. Biggest insight I got about myself this week

I realised I care about getting things right, not just getting them done. Several times this week I stopped to check whether my work actually matched the requirements instead of assuming it did. I pushed back when a saved memory value did not match my real code, and I would not settle for a blog post I was not happy with. That is a strength, but I also saw that it can slow me down. Knowing when "correct enough" is genuinely enough is something I want to balance better.

## 3. My biggest weakness I noticed

My clearest repeated loop was the screenshot workflow. I kept getting tangled up: retaking screenshots I did not need to, losing track of which capture matched which task, and once pushing a write-up where an image had not finished downloading, so it showed a broken icon on GitHub. Early on I also confused the regular terminal with the Claude Code terminal. These are small things, but they cost me time again and again.

## 4. One system I will implement from this week

After finishing every assignment, I will open the rendered page on GitHub and scan it for broken images and missing sections before I move on. I will do this as the very last step of each assignment, right after I push. It takes about five seconds and it catches exactly the kind of "downloaded a beat too late" mistake that bit me this week, so nothing incomplete ever reaches a reviewer.

## 5. What I learned about Agentic AI and DevOps

I learned that Agentic AI is not just a chatbot. It can follow structured workflows, run commands, connect to live services, and take real action. But the lesson of all lessons I got is that automation needs control. Hooks blocked a `terraform destroy` before it could run. Permissions decided what was allowed. Memory kept my conventions consistent across sessions. In every case, the agent did the heavy lifting while I stayed in the loop to review before anything shipped. That balance, automation with guardrails and a human in control, is what real DevOps looks like.

## 6. My Week 2 highlight

My highlight was the memory test. I saved three facts, closed everything down completely, and reopened a fresh session with no history. Claude still recalled what I had told it. Even better, it checked one saved fact against my actual code, found it was stale, and corrected it. Watching an AI remember and then verify itself across a full restart was the moment Week 2 really came together for me.
