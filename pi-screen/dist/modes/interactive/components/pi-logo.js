import { backgroundAnsi, foregroundAnsi, isAppleTerminalSession, rgbColor } from "@earendil-works/pi-tui";
import { theme } from "../theme/theme.js";
// Deeper navy Fairy-eye palette (Zenless Zone Zero).
const LID = rgbColor(9, 11, 26); // closed-lid interior, deepest navy
const LID_SHEEN = rgbColor(16, 20, 46); // faint lighter band inside the lid
const CASING = rgbColor(21, 26, 58); // outer casing ring
const SEAM = rgbColor(30, 56, 118); // seam between casing and glow
const GLOW = rgbColor(34, 84, 172); // deep blue glow ring
const CYAN = rgbColor(68, 168, 232); // cyan rim / iris ring
const SCLERA = rgbColor(230, 240, 254); // white of the eye
const PUPIL = rgbColor(8, 10, 24); // pupil
const RESET = "\x1b[0m";
const COLOR_BY_CELL = {
    L: LID,
    l: LID_SHEEN,
    N: CASING,
    B: SEAM,
    G: GLOW,
    C: CYAN,
    W: SCLERA,
    P: PUPIL,
};
/**
 * The Fairy eye logo: a 32x32 pixel grid rendered with half blocks into 16 terminal lines.
 * Each frame is stored as 32 strings of 32 characters; "." is transparent.
 *
 * The frames are successive stages of a blink, from fully open to fully shut:
 *   0 open, 1 mostly open, 2 half shut, 3 nearly shut, 4 a slit, 5 shut.
 * Animation loops should walk 0 -> 5 and back out again, then hold on frame 0.
 */
const FAIRY_EYE_FRAMES = [["................................","...........NCCCCCCCCN...........",".........NCCBBBBBBBBCCN.........",".......NCCBBBGGGGGGBBBCCN.......","......NCBBGGGGGGGGGGGGBBCN......",".....NCBBGGGCCCWWCCCGGGBBCN.....","....NCBGGGCWWWWWWWWWWCGGGBCN....","...NCBGGCCWWWWWWWWWWWWCCGGBCN...","...NBBGCCWWWWWWWWWWWWWWCCGBBN...","..NCBGGCWWWWWWWWWWWWWWWWCGGBCN..","..NBGGCWWWWWWWWWWWWWWWWWWCGGBN..",".NCBGGWWWWWWWCCCCCCWWWWWWWGGBCN.",".NBBGCWWWWWWCCPPPPCCWWWWWWCGBBN.",".NBGGCWWWWWCCPPPPPPCCWWWWWCGGBN.",".NBGGCWWWWWCPPPPPPPPCWWWWWCGGBN.",".NBGGWWWWWWCPPPPPPPPCWWWWWWGGBN.",".NBGGWWWWWWCPPPPPPPPCWWWWWWGGBN.",".NBGGCWWWWWCPPPPPPPPCWWWWWCGGBN.",".NBGGCWWWWWCCPPPPPPCCWWWWWCGGBN.",".NBBGCWWWWWWCCPPPPCCWWWWWWCGBBN.",".NNBGGWWWWWWWCCCCCCWWWWWWWGGBNN.","..NBGGCWWWWWWWWWWWWWWWWWWCGGBN..","..NNBGGCWWWWWWWWWWWWWWWWCGGBNN..","...NBBGCCWWWWWWWWWWWWWWCCGBBN...","...NNBGGCCWWWWWWWWWWWWCCGGBNN...","....NNBGGGCWWWWWWWWWWCGGGBNN....",".....NNBBGGGCCCWWCCCGGGBBNN.....","......NNBBGGGGGGGGGGGGBBNN......",".......NNNBBBGGGGGGBBBNNN.......",".........NNNBBBBBBBBNNN.........","...........NNNNNNNNNN...........","................................"],
    ["................................","...........NNNNNNNNNN...........",".........NNNllllllllNNN.........",".......NNNlllLLLLLLlllNNN.......","......NNllLLLLLLLLLLLLllNN......",".....NNllLLLLLLLLLLLLLLllNN.....","....NNlLLLLLLLLLLLLLLLLLLlNN....","...NNlLLLLLLLLCCCCLLLLLLLLlNN...","...NllLLLCCCCCWWWWCCCCCLLLllN...","..NNlLCCCWWWWWWWWWWWWWWCCCLlNN..","..NCCCCWWWWWWWWWWWWWWWWWWCCCCN..",".NCBGGWWWWWWWCCCCCCWWWWWWWGGBCN.",".NBBGCWWWWWWCCPPPPCCWWWWWWCGBBN.",".NBGGCWWWWWCCPPPPPPCCWWWWWCGGBN.",".NBGGCWWWWWCPPPPPPPPCWWWWWCGGBN.",".NBGGWWWWWWCPPPPPPPPCWWWWWWGGBN.",".NBGGWWWWWWCPPPPPPPPCWWWWWWGGBN.",".NBGGCWWWWWCPPPPPPPPCWWWWWCGGBN.",".NBGGCWWWWWCCPPPPPPCCWWWWWCGGBN.",".NBBGCWWWWWWCCPPPPCCWWWWWWCGBBN.",".NNBGGWWWWWWWCCCCCCWWWWWWWGGBNN.","..NBGGCWWWWWWWWWWWWWWWWWWCGGBN..","..NNBGGCWWWWWWWWWWWWWWWWCGGBNN..","...NBBGCCWWWWWWWWWWWWWWCCGBBN...","...NNBGGCCWWWWWWWWWWWWCCGGBNN...","....NNBGGGCWWWWWWWWWWCGGGBNN....",".....NNBBGGGCCCWWCCCGGGBBNN.....","......NNBBGGGGGGGGGGGGBBNN......",".......NNNBBBGGGGGGBBBNNN.......",".........NNNBBBBBBBBNNN.........","...........NNNNNNNNNN...........","................................"],
    ["................................","...........NNNNNNNNNN...........",".........NNNllllllllNNN.........",".......NNNlllLLLLLLlllNNN.......","......NNllLLLLLLLLLLLLllNN......",".....NNllLLLLLLLLLLLLLLllNN.....","....NNlLLLLLLLLLLLLLLLLLLlNN....","...NNlLLLLLLLLLLLLLLLLLLLLlNN...","...NllLLLLLLLLLLLLLLLLLLLLllN...","..NNlLLLLLLLLLLLLLLLLLLLLLLlNN..","..NlLLLLLLLLLLLLLLLLLLLLLLLLlN..",".NNlLLLLLLLLLLLLLLLLLLLLLLLLlNN.",".NllLLLLLLLLLLLLLLLLLLLLLLLLllN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLCCCCCCCCCCLLLLLLLLlN.",".NlLLLLCCCCCPPPPPPPPCCCCCLLLLlN.",".NlLLCCWWWWCPPPPPPPPCWWWWCCLLlN.",".NlCCCWWWWWCCPPPPPPCCWWWWWCCClN.",".NlBGCWWWWWWCCPPPPCCWWWWWWCGBlN.",".NNBGGWWWWWWWCCCCCCWWWWWWWGGBNN.","..NBGGCWWWWWWWWWWWWWWWWWWCGGBN..","..NNBGGCWWWWWWWWWWWWWWWWCGGBNN..","...NBBGCCWWWWWWWWWWWWWWCCGBBN...","...NNBGGCCWWWWWWWWWWWWCCGGBNN...","....NNBGGGCWWWWWWWWWWCGGGBNN....",".....NNBBGGGCCCWWCCCGGGBBNN.....","......NNBBGGGGGGGGGGGGBBNN......",".......NNNBBBGGGGGGBBBNNN.......",".........NNNBBBBBBBBNNN.........","...........NNNNNNNNNN...........","................................"],
    ["................................","...........NNNNNNNNNN...........",".........NNNllllllllNNN.........",".......NNNlllLLLLLLlllNNN.......","......NNllLLLLLLLLLLLLllNN......",".....NNllLLLLLLLLLLLLLLllNN.....","....NNlLLLLLLLLLLLLLLLLLLlNN....","...NNlLLLLLLLLLLLLLLLLLLLLlNN...","...NllLLLLLLLLLLLLLLLLLLLLllN...","..NNlLLLLLLLLLLLLLLLLLLLLLLlNN..","..NlLLLLLLLLLLLLLLLLLLLLLLLLlN..",".NNlLLLLLLLLLLLLLLLLLLLLLLLLlNN.",".NllLLLLLLLLLLLLLLLLLLLLLLLLllN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NllLLLLLLLLLLLLLLLLLLLLLLLLllN.",".NNlLLLLLLLLLLLLLLLLLLLLLLLLlNN.","..NlLLLLLLLCCCCCCCCCCLLLLLLLlN..","..NNlLLLCCCWWWWWWWWWWCCCLLLlNN..","...NlCCCCWWWWWWWWWWWWWWCCCClN...","...NNBGGCCWWWWWWWWWWWWCCGGBNN...","....NNBGGGCWWWWWWWWWWCGGGBNN....",".....NNBBGGGCCCWWCCCGGGBBNN.....","......NNBBGGGGGGGGGGGGBBNN......",".......NNNBBBGGGGGGBBBNNN.......",".........NNNBBBBBBBBNNN.........","...........NNNNNNNNNN...........","................................"],
    ["................................","...........NNNNNNNNNN...........",".........NNNllllllllNNN.........",".......NNNlllLLLLLLlllNNN.......","......NNllLLLLLLLLLLLLllNN......",".....NNllLLLLLLLLLLLLLLllNN.....","....NNlLLLLLLLLLLLLLLLLLLlNN....","...NNlLLLLLLLLLLLLLLLLLLLLlNN...","...NllLLLLLLLLLLLLLLLLLLLLllN...","..NNlLLLLLLLLLLLLLLLLLLLLLLlNN..","..NlLLLLLLLLLLLLLLLLLLLLLLLLlN..",".NNlLLLLLLLLLLLLLLLLLLLLLLLLlNN.",".NllLLLLLLLLLLLLLLLLLLLLLLLLllN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NllLLLLLLLLLLLLLLLLLLLLLLLLllN.",".NNlLLLLLLLLLLLLLLLLLLLLLLLLlNN.","..NlLLLLLLLLLLLLLLLLLLLLLLLLlN..","..NNlLLLLLLLLLLLLLLLLLLLLLLlNN..","...NllLLLLLLLLLLLLLLLLLLLLllN...","...NNlLLLLLLLLLLLLLLLLLLLLlNN...","....NNlLLLLLLLLLLLLLLLLLLlNN....",".....NNllLLLLLLLLLLLLLLllNN.....","......NNllCCCCCCCCCCCCllNN......",".......NNNBBBGGGGGGBBBNNN.......",".........NNNBBBBBBBBNNN.........","...........NNNNNNNNNN...........","................................"],
    ["................................","...........NNNNNNNNNN...........",".........NNNllllllllNNN.........",".......NNNlllLLLLLLlllNNN.......","......NNllLLLLLLLLLLLLllNN......",".....NNllLLLLLLLLLLLLLLllNN.....","....NNlLLLLLLLLLLLLLLLLLLlNN....","...NNlLLLLLLLLLLLLLLLLLLLLlNN...","...NllLLLLLLLLLLLLLLLLLLLLllN...","..NNlLLLLLLLLLLLLLLLLLLLLLLlNN..","..NlLLLLLLLLLLLLLLLLLLLLLLLLlN..",".NNlLLLLLLLLLLLLLLLLLLLLLLLLlNN.",".NllLLLLLLLLLLLLLLLLLLLLLLLLllN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NlLLLLLLLLLLLLLLLLLLLLLLLLLLlN.",".NllLLLLLLLLLLLLLLLLLLLLLLLLllN.",".NNlLLLLLLLLLLLLLLLLLLLLLLLLlNN.","..NlLLLLLLLLLLLLLLLLLLLLLLLLlN..","..NNlLLLLLLLLLLLLLLLLLLLLLLlNN..","...NllLLLLLLLLLLLLLLLLLLLLllN...","...NNlLLLLLLLLLLLLLLLLLLLLlNN...","....NNlLLLLLLLLLLLLLLLLLLlNN....",".....NNllLLLLLLLLLLLLLLllNN.....","......NNllLLLLLLLLLLLLllNN......",".......NNNlllLLLLLLlllNNN.......",".........NNNllllllllNNN.........","...........NNNNNNNNNN...........","................................"]];
function renderFrame(rows) {
    const mode = theme.getColorMode();
    const fg = (color) => foregroundAnsi(color, mode);
    const bg = (color) => backgroundAnsi(color, mode);
    const lines = [];
    for (let y = 0; y < rows.length; y += 2) {
        const top = rows[y];
        const bottom = y + 1 < rows.length ? rows[y + 1] : null;
        let line = "";
        for (let x = 0; x < top.length; x++) {
            const topCell = COLOR_BY_CELL[top[x]];
            const bottomCell = bottom ? COLOR_BY_CELL[bottom[x]] : undefined;
            if (!topCell && !bottomCell) {
                line += " ";
            }
            else if (!topCell) {
                line += `${fg(bottomCell)}▄${RESET}`;
            }
            else if (!bottomCell) {
                line += `${fg(topCell)}▀${RESET}`;
            }
            else if (top[x] === bottom[x]) {
                line += `${fg(topCell)}█${RESET}`;
            }
            else {
                line += `${fg(topCell)}${bg(bottomCell)}▀${RESET}`;
            }
        }
        lines.push(line);
    }
    return lines;
}
/** Number of blink stages (0 = open, FRAME_COUNT - 1 = shut). */
export const FAIRY_EYE_FRAME_COUNT = FAIRY_EYE_FRAMES.length;
/** Width of the logo in terminal columns (every frame is the same grid). */
export const FAIRY_EYE_WIDTH = FAIRY_EYE_FRAMES[0][0].length;
/**
 * The Fairy eye logo, 32 cells wide and 16 lines tall. Pass a frame index (0-5) to pick a blink
 * stage; frame 0 is the fully open eye.
 */
export function piLogoLines(frameIndex = 0) {
    const index = Math.max(0, Math.min(FAIRY_EYE_FRAMES.length - 1, Math.floor(frameIndex) || 0));
    return renderFrame(FAIRY_EYE_FRAMES[index]);
}
/** Full logo as a single multi-line string for Text components. */
export function piLogoText(frameIndex = 0) {
    return piLogoLines(frameIndex).join("\n");
}
/**
 * Whether the terminal renders the half-block logo correctly. Apple Terminal draws gaps between
 * rows and misaligns the half blocks, so it gets the text wordmark instead.
 */
export function supportsPiLogo() {
    return !isAppleTerminalSession();
}
/** Text fallback for the logo: "Fairy" with the eye's cyan. */
export function piWordmark() {
    const mode = theme.getColorMode();
    return `${foregroundAnsi(CYAN, mode)}Fairy${RESET}`;
}
//# sourceMappingURL=pi-logo.js.map
