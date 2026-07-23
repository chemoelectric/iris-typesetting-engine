import { DocumentTemplate } from '../types';

export const DOCUMENT_TEMPLATES: DocumentTemplate[] = [
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

