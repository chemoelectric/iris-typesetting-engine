import { DocumentTemplate } from '../types';

export const DOCUMENT_TEMPLATES: DocumentTemplate[] = [
  {
    id: 'twain_wit_inspirations',
    title: 'Wit Inspirations Of The "Two-Year-Olds" (Mark Twain)',
    category: 'Microtypography',
    description: 'Libre Baskerville typesetting optimized for Canon MF4890dw (600 DPI) with John Baskerville generous leading, baseline grid & harmonic migraine-dampened kerning.',
    markup: `\\text{Springfield, Mass., Nov. 1879.}
\\text{Baby speech, to an adult, is a sweet and gentle music; but to another baby it is plain English, concise and to the point.}
\\text{A two-year-old child, sitting in its high chair at dinner, observed a fly crawling over the table-cloth.}
\\text{It pointed its little chubby finger at the intruder and remarked with grave deliberation:}
\\text{"Dere's a bug."}
\\text{The mother, eager to encourage the infant intellect, asked: "What is the bug doing, darling?"}
\\text{The child considered the problem in silent meditation for a moment, then gave utterance to this profound result:}
\\text{"He's a-walkin'."}
\\text{This was not mere idle chatter; it was a terse, scientific statement of a physical phenomenon, stripped of all rhetorical ornament.}`,
  },
  {
    id: 'cl411_unified_field',
    title: 'Cl(4,1,1) Unified Field Equation',
    category: 'Unified Field Theory',
    description: 'Unified electromagnetic and gravity multivector field equation in absolute 3D space and unidirectional time.',
    markup: `F = \\nabla_{Cl(4,1,1)} A = E + i B + G + S`,
  },
  {
    id: 'absolute_time_wave',
    title: 'Absolute Unidirectional Wave Equation',
    category: 'Cl(4,1,1) Dynamics',
    description: '3D absolute spatial continuum wave equation governed by absolute unidirectional time progression.',
    markup: `\\frac{\\partial^2 \\Psi}{\\partial t^2} + k^2 \\nabla^2 \\Psi = 0`,
  },
  {
    id: 'maxwell_clifford_tensor',
    title: 'Maxwell-Clifford Invariant Energy Tensor',
    category: 'Tensor & Matrices',
    description: 'Unified electromagnetic and gravitational energy-momentum tensor matrix in Cl(4,1,1) multivector algebra.',
    markup: `T_{\\mu \\nu} = \\frac{1}{4 \\pi} \\begin{matrix} E^2 + B^2 & G_x \\\\ G_y & E_z - B_z \\end{matrix}`,
  },
  {
    id: 'maxent_jaynes',
    title: 'Jaynesian MaxEnt Partition Function',
    category: 'Jaynesian MaxEnt',
    description: 'Maximum entropy probability partition function Z(λ) subject to energy and particle constraints.',
    markup: `Z(\\lambda) = \\sum_{i=1}^{N} e^{-\\lambda_1 E_i - \\lambda_2 N_i}`,
  },
  {
    id: 'iris_logarithmic',
    title: 'Counting-Iris Sub-Pixel Transformation',
    category: 'Microtypography',
    description: 'Sub-pixel discrete coordinate manifold mapping physical distance to Iris logarithmic scales.',
    markup: `\\iota = \\lfloor \\log_2 r \\rfloor, \\quad k = \\lfloor 65536 \\cdot (r \\cdot 2^{-\\iota}) \\rfloor`,
  },
  {
    id: 'gaussian_integral',
    title: 'Gaussian Definite Integral',
    category: 'Microtypography',
    description: 'Classic Gaussian integral from -∞ to +∞ evaluated to √π.',
    markup: `\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}`,
  },
];

