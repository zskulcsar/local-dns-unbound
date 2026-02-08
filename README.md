# local-dns-unbound

The purpose of this project is to provide an automated way to install various privacy related tools on a linux box (either remote or local) using automation.

*Notice: using AI assited coding here is perfectly fine, I'll do myself as well. As I see it, if you threat them as **"active knowledge base"** you'll be just fine and will enhance your knowledge and likely make you a better engineer.*

**TODO**: License. We'll need to figure out what suits the best considering the many places this project draws from (and redistributes work by others)

## Sources

The project stands on the should of giants (as it happens most of the times anyway). Here is the list for work directly distributed as part of the project as opposed to dependencies.:

- (ar51an/unbound-dashboard)[https://github.com/ar51an/unbound-dashboard]
- (ar51an/unbound-redis)[https://github.com/ar51an/unbound-redis]
- (ar51an/unbound-exporter)[https://github.com/ar51an/unbound-exporter]
- (opencoff/unbound-adblock)[https://github.com/opencoff/unbound-adblock]


## unbound (DNS caching and some privacy)

- [ ] unbound install via ansible
    - [ ] Privacy enchanced DNS
    - [ ] (Semi) persistent cache via Redis
    - [ ] Beautiful dashboard
- [ ] adblock (domain block)
- [ ] Redis install via ansible
- [ ] Log stack (Loki and Promtail)
- [ ] 

## Open source SIEM

Wazuh

- TODO:

### Future

- Use Loki as indexer instead of elasticsearch; Likely this is a hue piece of work in itself


## Open source AV

ClamAV

- TODO:

## Monitoring

### Loki

Loki and Promtail

- TODO: 

### Grafana

Grafana

- TODO:

### Prometheus

Prometheus

- TODO:

## Active knowledge-base

Engineers are typical split in the middle: against and for AI tools and it seems it's based on the idea that AI agents / tools will replace the engineer. I think this is wrong. And also I think reframing what these tools are will help.

My offer, threat theam as an active knowledge base as follows:
* Knowledge base: LLMs are exceptionally good compression engines. See (Silicon Valley)[]. Just to illustrate, the Common Crawl is about 700TB in size as of 2026 and widely used for training LLMs. The output as a model is a couple of GB. All the knowledge in the common-crawl (and most probably more sources) are compressed down with over 1000x.
* Active: in the early days we had encyplopedias distributed over CD, as a book. These days we have (Wikipedia)[] but the best one can do is search them. With the LLMs one can interact with the Knowledge in ways search never was able to do. In many ways, this liberates the knowledge.

Threat it as such and it will help you learn and understand things way deeper than just by searching.
