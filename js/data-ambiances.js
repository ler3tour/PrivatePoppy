/*
 * Bibliothèque d'ambiances déco, inspirée des tags Pinterest.
 * Chaque style : palette 5 couleurs, matériaux phares et tags de recherche.
 */
const AMBIANCES_STYLES = [
  {
    id: "scandinave",
    nom: "Scandinave",
    emoji: "🌿",
    description: "Lumière, bois clair et lignes douces : le hygge nordique qui agrandit les petites surfaces.",
    palette: ["#F5F1EA", "#E4D8C8", "#B4C4BC", "#8A9B8E", "#3E4A45"],
    materiaux: ["chêne clair", "laine bouclée", "lin lavé", "céramique mate"],
    tags: ["#hygge", "#scandinave", "#boisclair", "#minimal", "#cosy", "#lumineux"]
  },
  {
    id: "industriel",
    nom: "Industriel",
    emoji: "🏭",
    description: "Esprit loft new-yorkais : briques, métal noir et cuir patiné pour un caractère assumé.",
    palette: ["#2B2B2B", "#5C5049", "#A6653F", "#C9B7A2", "#8C8C88"],
    materiaux: ["métal noir", "brique rouge", "cuir fauve", "béton ciré"],
    tags: ["#industriel", "#loft", "#brique", "#metal", "#vintage", "#atelier"]
  },
  {
    id: "boheme",
    nom: "Bohème",
    emoji: "🪶",
    description: "Rotin, macramé et textiles superposés : une déco voyageuse, chaleureuse et décontractée.",
    palette: ["#F3E6D4", "#E0B589", "#C97C5D", "#7A9E7E", "#4E3D30"],
    materiaux: ["rotin", "macramé", "jute", "terre cuite"],
    tags: ["#boheme", "#rotin", "#macrame", "#plantes", "#terracotta", "#ethnique"]
  },
  {
    id: "japandi",
    nom: "Japandi",
    emoji: "🎋",
    description: "Fusion Japon-Scandinavie : épure zen, matières naturelles et artisanat wabi-sabi.",
    palette: ["#EFEAE3", "#D8CFC0", "#A79B87", "#6D6A5F", "#2F2E2A"],
    materiaux: ["bois cendré", "papier washi", "grès brut", "bambou"],
    tags: ["#japandi", "#wabisabi", "#zen", "#epure", "#naturel", "#minimal"]
  },
  {
    id: "minimaliste",
    nom: "Minimaliste",
    emoji: "⬜",
    description: "Moins mais mieux : volumes nets, rangements invisibles et palette monochrome apaisante.",
    palette: ["#FFFFFF", "#F2F2F0", "#D9D9D6", "#9FA0A0", "#1F2020"],
    materiaux: ["laque mate", "verre", "acier brossé", "microciment"],
    tags: ["#minimal", "#monochrome", "#epure", "#moderne", "#blanc", "#design"]
  },
  {
    id: "artdeco",
    nom: "Art déco",
    emoji: "✨",
    description: "Géométrie, velours profonds et laiton doré : le glamour des années folles revisité.",
    palette: ["#1E2A38", "#14504A", "#C9A227", "#B76E79", "#F4EDE2"],
    materiaux: ["velours émeraude", "laiton", "marbre", "miroir fumé"],
    tags: ["#artdeco", "#velours", "#laiton", "#geometrique", "#chic", "#glamour"]
  },
  {
    id: "mediterraneen",
    nom: "Méditerranéen",
    emoji: "🌊",
    description: "Chaux blanche, bleu profond et terre cuite : la dolce vita entre Grèce et Provence.",
    palette: ["#F7F3EA", "#E8D5B5", "#D89C6A", "#4E7A9B", "#274B63"],
    materiaux: ["chaux", "terre cuite", "olivier", "zellige"],
    tags: ["#mediterraneen", "#bordemer", "#terracotta", "#bleu", "#provence", "#naturel"]
  },
  {
    id: "campagnechic",
    nom: "Campagne chic",
    emoji: "🏡",
    description: "Poutres, lin froissé et teintes crème : l'élégance rustique d'une maison de famille.",
    palette: ["#F6F1E7", "#E3D9C6", "#C9BBA3", "#8F9779", "#5B4636"],
    materiaux: ["bois patiné", "lin froissé", "pierre naturelle", "osier"],
    tags: ["#campagne", "#rustique", "#farmhouse", "#lin", "#cosy", "#authentique"]
  },
  {
    id: "vintage70",
    nom: "Vintage 70's",
    emoji: "🟠",
    description: "Courbes rétro, orange brûlé et velours côtelé : le funk chaleureux des seventies.",
    palette: ["#F2E3C6", "#E8A33D", "#C1552F", "#7C5836", "#3F5544"],
    materiaux: ["velours côtelé", "teck", "céramique émaillée", "moquette bouclée"],
    tags: ["#vintage", "#retro", "#seventies", "#orange", "#courbes", "#funky"]
  },
  {
    id: "moderneluxe",
    nom: "Moderne luxe",
    emoji: "🖤",
    description: "Contrastes marbre et noir, éclairages indirects : une élégance hôtel cinq étoiles.",
    palette: ["#101014", "#3A3A40", "#8C7853", "#D6CFC4", "#F5F4F1"],
    materiaux: ["marbre noir", "noyer", "laiton brossé", "verre fumé"],
    tags: ["#luxe", "#moderne", "#marbre", "#contraste", "#hotelchic", "#design"]
  }
];
