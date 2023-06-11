const MetarTaf = require("metar-taf-parser");

export class MetarTafParser {
    static parseMetar(metar) {
        return JSON.stringify(MetarTaf.parseMetar(metar));
    }
}
