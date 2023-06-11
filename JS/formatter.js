const {
    Descriptive,
    Intensity,
    Phenomenon,
    SpeedUnit,
    CloudQuantity,
    CloudType,
    DistanceUnit,
    ValueIndicator,
    Visibility,
    ICloud,
    TurbulenceIntensity,
    IcingIntensity,
} = require("metar-taf-parser");

const FlightCategory = {
    VFR: "VFR",
    MVFR: "MVFR",
    IFR: "IFR",
    LIFR: "LIFR",
};

function formatIndicator(indicator) {
    switch (indicator) {
        case ValueIndicator.GreaterThan:
            return "or greater";
        case ValueIndicator.LessThan:
            return "or less";
        default:
            return "";
    }
}

export function formatPhenomenon(phenomenon) {
    switch (phenomenon) {
        case Phenomenon.RAIN:
            return "Rain";
        case Phenomenon.DRIZZLE:
            return "Drizzle";
        case Phenomenon.SNOW:
            return "Snow";
        case Phenomenon.SNOW_GRAINS:
            return "Snow grains";
        case Phenomenon.ICE_PELLETS:
            return "Ice pellets";
        case Phenomenon.ICE_CRYSTALS:
            return "Ice crystals";
        case Phenomenon.HAIL:
            return "Hail";
        case Phenomenon.SMALL_HAIL:
            return "Small hail";
        case Phenomenon.UNKNOW_PRECIPITATION:
            return "Unknown precipitation";
        case Phenomenon.FOG:
            return "Fog";
        case Phenomenon.VOLCANIC_ASH:
            return "Volcanic ash";
        case Phenomenon.MIST:
            return "Mist";
        case Phenomenon.HAZE:
            return "Haze";
        case Phenomenon.WIDESPREAD_DUST:
            return "Widespread dust";
        case Phenomenon.SMOKE:
            return "Smoke";
        case Phenomenon.SAND:
            return "Sand";
        case Phenomenon.SPRAY:
            return "Spray";
        case Phenomenon.SQUALL:
            return "Squall";
        case Phenomenon.SAND_WHIRLS:
            return "Sand whirls";
        case Phenomenon.THUNDERSTORM:
            return "Thunderstorm";
        case Phenomenon.DUSTSTORM:
            return "Duststorm";
        case Phenomenon.SANDSTORM:
            return "Sandstorm";
        case Phenomenon.FUNNEL_CLOUD:
            return "Funnel cloud";
        case Phenomenon.NO_SIGNIFICANT_WEATHER:
            return "No significant weather";
    }
}

function formatDescriptive(descriptive, hasPhenomenon) {
    switch (descriptive) {
        case Descriptive.SHOWERS:
            return `Showers${hasPhenomenon ? " of" : ""}`;
        case Descriptive.SHALLOW:
            return "Shallow";
        case Descriptive.PATCHES:
            return `Patches${hasPhenomenon ? " of" : ""}`;
        case Descriptive.PARTIAL:
            return "Partial";
        case Descriptive.DRIFTING:
            return "Drifting";
        case Descriptive.THUNDERSTORM:
            return "Thunderstorm";
        case Descriptive.BLOWING:
            return "Blowing";
        case Descriptive.FREEZING:
            return "Freezing";
        default:
            return "";
    }
}

function formatIntensity(intensity) {
    switch (intensity) {
        case Intensity.LIGHT:
            return "Light";
        case Intensity.MODERATE:
            return "Moderate";
        case Intensity.HEAVY:
            return "Heavy";
        default:
            return "";
    }
}

function formatSpeed(speed) {
    if (speed.unit === SpeedUnit.KT) {
        return `${speed.value} knots`;
    } else if (speed.unit === SpeedUnit.MPS) {
        return `${speed.value} meters per second`;
    } else {
        return "";
    }
}

export function formatCloudQuantity(cloud) {
    let ret = "";

    switch (cloud.quantity) {
        case CloudQuantity.NSC:
            return "No significant clouds";
        case CloudQuantity.SKC:
            return "Clear sky";
        case CloudQuantity.BKN:
            ret += "Broken clouds";
            break;
        case CloudQuantity.FEW:
            ret += "Few clouds";
            break;
        case CloudQuantity.SCT:
            ret += "Scattered clouds";
            break;
        case CloudQuantity.OVC:
            ret += "Overcast";
    }

    if (cloud.type) {
        ret += ` (${formatCloudType(cloud.type)})`;
    }

    ret += ` at ${cloud.height?.toLocaleString()}ft`;

    return ret;
}

function formatCloudType(type) {
    switch (type) {
        case CloudType.CB:
            return "Cumulonimbus";
        case CloudType.TCU:
            return "Towering cumulus";
        case CloudType.CI:
            return "Cirrus";
        case CloudType.CC:
            return "Cirrocumulus";
        case CloudType.CS:
            return "Cirrostratus";
        case CloudType.AC:
            return "Altocumulus";
        case CloudType.ST:
            return "Stratus";
        case CloudType.CU:
            return "Cumulus";
        case CloudType.AS:
            return "Astrostratus";
        case CloudType.NS:
            return "Nimbostratus";
        case CloudType.SC:
            return "Stratocumulus";
    }
}

function formatDistance(distance) {
    if (distance.unit === DistanceUnit.M) {
        return `${distance.value} meters`;
    } else if (distance.unit === DistanceUnit.KM) {
        return `${distance.value} kilometers`;
    } else {
        return "";
    }
}

export function formatFlightCategory(category) {
    switch (category) {
        case FlightCategory.VFR:
            return "Visual Flight Rules (VFR)";
        case FlightCategory.MVFR:
            return "Marginal Visual Flight Rules (MVFR)";
        case FlightCategory.IFR:
            return "Instrument Flight Rules (IFR)";
        case FlightCategory.LIFR:
            return "Low Instrument Flight Rules (LIFR)";
        default:
            return "";
    }
}

function determineCeilingFromClouds(clouds) {
    let ceiling;

    clouds.forEach((cloud) => {
        if (
            cloud.height != null &&
            cloud.height < (ceiling?.height || Infinity) &&
            (cloud.quantity === CloudQuantity.OVC ||
                cloud.quantity === CloudQuantity.BKN)
        ) {
            ceiling = cloud;
        }
    });

    return ceiling;
}

function convertToMiles(visibility) {
    if (!visibility) return;

    switch (visibility.unit) {
        case DistanceUnit.StatuteMiles:
            return visibility.value;
        case DistanceUnit.Meters:
            const distance = visibility.value * 0.000621371;

            if (visibility.value % 1000 === 0 || visibility.value === 9999)
                return Math.round(distance);

            return +distance.toFixed(2);
    }
}

export function getFlightCategory(visibility, clouds, verticalVisibility) {
    const convertedVisibility = convertToMiles(visibility);
    const distance =
        convertedVisibility != null ? convertedVisibility : Infinity;
    const height =
        determineCeilingFromClouds(clouds)?.height ??
        verticalVisibility ??
        Infinity;

    let flightCategory = FlightCategory.VFR;

    if (height <= 3000 || distance <= 5) flightCategory = FlightCategory.MVFR;
    if (height <= 1000 || distance <= 3) flightCategory = FlightCategory.IFR;
    if (height <= 500 || distance <= 1) flightCategory = FlightCategory.LIFR;

    return flightCategory;
}

function formatVisibility(visibility) {
    if (visibility) {
        if (visibility.distance) {
            const distance = formatDistance(visibility.distance);
            const indicator = formatIndicator(visibility.indicator);
            return `${distance} ${indicator}`;
        } else if (visibility.cavok) {
            return "CAVOK (Ceiling And Visibility OK)";
        }
    }
    return "";
}

export function formatClouds(clouds) {
    if (clouds.length === 0) {
        return "";
    }

    let result = "";
    for (const cloud of clouds) {
        const quantity = formatCloudQuantity(cloud);

        result += `${quantity}\n`;
    }
    return result.slice(0, -1); // Remove trailing comma and space
}

function formatTurbulence(turbulence) {
    if (turbulence.intensity) {
        const intensity = formatIntensity(turbulence.intensity);
        return `Turbulence: ${intensity}`;
    }
    return "";
}

function formatIcing(icing) {
    if (icing.intensity) {
        const intensity = formatIntensity(icing.intensity);
        return `Icing: ${intensity}`;
    }
    return "";
}

function parseMETAR(metar) {
    const {
        temperature,
        dewPoint,
        wind,
        visibility,
        weather,
        clouds,
        flightCategory,
        turbulence,
        icing,
    } = metar;
    const temperatureString = temperature ? `${temperature}°C` : "";
    const dewPointString = dewPoint ? `${dewPoint}°C` : "";
    const windString = wind ? formatWind(wind) : "";
    const visibilityString = visibility ? formatVisibility(visibility) : "";
    const weatherString = weather ? `Weather: ${weather}` : "";
    const cloudsString = clouds ? formatClouds(clouds) : "";
    const flightCategoryString = flightCategory
        ? `Flight category: ${formatFlightCategory(flightCategory)}`
        : "";
    const turbulenceString = turbulence ? formatTurbulence(turbulence) : "";
    const icingString = icing ? formatIcing(icing) : "";

    const parsedMETAR = [
        temperatureString,
        dewPointString,
        windString,
        visibilityString,
        weatherString,
        cloudsString,
        flightCategoryString,
        turbulenceString,
        icingString,
    ].filter((item) => item !== "");

    return parsedMETAR.join("\n");
}
