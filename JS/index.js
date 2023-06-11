const MetarTaf = require("metar-taf-parser");
const Formatter = require("./formatter");

export class MetarTafParser {
    static parseMetar(metar) {
        return JSON.stringify(MetarTaf.parseMetar(metar));
    }

    static getFlightCategory(metar) {
        const parsedMetar = MetarTaf.parseMetar(metar);
        return Formatter.getFlightCategory(
            parsedMetar.visibility,
            parsedMetar.clouds,
            parsedMetar.verticalVisibility
        );
    }

    static formatFlightCategory(category) {
        return Formatter.formatFlightCategory(category);
    }

    static formatClouds(metar) {
        const parsedMetar = MetarTaf.parseMetar(metar);
        return Formatter.formatClouds(parsedMetar.clouds);
    }
}
