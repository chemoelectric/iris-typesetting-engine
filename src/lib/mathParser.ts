/**
 * High-Precision TeX / Iris Math Markup Parser
 * Tokenizes TeX string input and generates a strongly typed MathASTNode tree.
 */

import { MathASTNode, MathNodeType } from '../types';

let idCounter = 0;
function genId(): string {
  return `node_${++idCounter}`;
}

export function parseMathMarkup(input: string): MathASTNode {
  idCounter = 0;
  const cleaned = input.trim();
  const tokens = tokenize(cleaned);
  const rootChildren = parseTokenList(tokens);

  return {
    id: genId(),
    type: 'group',
    children: rootChildren,
  };
}

interface Token {
  type: 'cmd' | 'char' | 'group_open' | 'group_close' | 'sub' | 'sup' | 'matrix_open' | 'matrix_close' | 'row_sep' | 'col_sep';
  value: string;
}

function tokenize(str: string): Token[] {
  const tokens: Token[] = [];
  let i = 0;

  while (i < str.length) {
    const ch = str[i];

    if (/\s/.test(ch)) {
      i++;
      continue;
    }

    if (ch === '\\') {
      // Command / Symbol
      let cmd = '\\';
      i++;
      while (i < str.length && /[a-zA-Z]/.test(str[i])) {
        cmd += str[i];
        i++;
      }

      if (cmd === '\\begin') {
        // Check for matrix or env
        let env = '';
        if (str[i] === '{') {
          i++;
          while (i < str.length && str[i] !== '}') {
            env += str[i];
            i++;
          }
          if (str[i] === '}') i++;
        }
        tokens.push({ type: 'matrix_open', value: env || 'matrix' });
      } else if (cmd === '\\end') {
        let env = '';
        if (str[i] === '{') {
          i++;
          while (i < str.length && str[i] !== '}') {
            env += str[i];
            i++;
          }
          if (str[i] === '}') i++;
        }
        tokens.push({ type: 'matrix_close', value: env || 'matrix' });
      } else {
        tokens.push({ type: 'cmd', value: cmd });
      }
      continue;
    }

    if (ch === '{') {
      tokens.push({ type: 'group_open', value: '{' });
      i++;
      continue;
    }
    if (ch === '}') {
      tokens.push({ type: 'group_close', value: '}' });
      i++;
      continue;
    }
    if (ch === '_') {
      tokens.push({ type: 'sub', value: '_' });
      i++;
      continue;
    }
    if (ch === '^') {
      tokens.push({ type: 'sup', value: '^' });
      i++;
      continue;
    }
    if (ch === '&') {
      tokens.push({ type: 'col_sep', value: '&' });
      i++;
      continue;
    }
    if (ch === '\\' && str[i + 1] === '\\') {
      tokens.push({ type: 'row_sep', value: '\\\\' });
      i += 2;
      continue;
    }

    tokens.push({ type: 'char', value: ch });
    i++;
  }

  return tokens;
}

function parseTokenList(tokens: Token[]): MathASTNode[] {
  const nodes: MathASTNode[] = [];
  let i = 0;

  while (i < tokens.length) {
    const token = tokens[i];

    if (token.type === 'cmd') {
      if (token.value === '\\frac') {
        i++;
        const numGroup = parseNextGroupOrToken(tokens, i);
        i = numGroup.nextIdx;
        const denGroup = parseNextGroupOrToken(tokens, i);
        i = denGroup.nextIdx;

        nodes.push({
          id: genId(),
          type: 'fraction',
          numerator: numGroup.node,
          denominator: denGroup.node,
        });
        continue;
      }

      if (token.value === '\\sqrt') {
        i++;
        const group = parseNextGroupOrToken(tokens, i);
        i = group.nextIdx;

        nodes.push({
          id: genId(),
          type: 'root',
          nucleus: group.node,
        });
        continue;
      }

      if (token.value === '\\int' || token.value === '\\sum') {
        const opType: MathNodeType = token.value === '\\int' ? 'integral' : 'summation';
        let lowerLimit: MathASTNode | undefined;
        let upperLimit: MathASTNode | undefined;
        i++;

        // Check for _ and ^ limits
        while (i < tokens.length && (tokens[i].type === 'sub' || tokens[i].type === 'sup')) {
          if (tokens[i].type === 'sub') {
            i++;
            const subGrp = parseNextGroupOrToken(tokens, i);
            lowerLimit = subGrp.node;
            i = subGrp.nextIdx;
          } else if (tokens[i].type === 'sup') {
            i++;
            const supGrp = parseNextGroupOrToken(tokens, i);
            upperLimit = supGrp.node;
            i = supGrp.nextIdx;
          }
        }

        nodes.push({
          id: genId(),
          type: opType,
          value: token.value,
          lowerLimit,
          upperLimit,
        });
        continue;
      }

      // Symbol
      const symbolMap: Record<string, string> = {
        '\\alpha': 'α',
        '\\beta': 'β',
        '\\gamma': 'γ',
        '\\delta': 'δ',
        '\\theta': 'θ',
        '\\lambda': 'λ',
        '\\mu': 'μ',
        '\\pi': 'π',
        '\\sigma': 'σ',
        '\\psi': 'ψ',
        '\\phi': 'ϕ',
        '\\omega': 'ω',
        '\\hbar': 'ℏ',
        '\\partial': '∂',
        '\\infty': '∞',
        '\\nabla': '∇',
        '\\pm': '±',
        '\\approx': '≈',
        '\\neq': '≠',
        '\\le': '≤',
        '\\ge': '≥',
        '\\in': '∈',
        '\\rightarrow': '→',
        '\\dagger': '†',
        '\\cdot': '·',
        '\\cdotp': '·',
        '\\times': '×',
      };

      const symVal = symbolMap[token.value] || token.value.replace('\\', '');
      nodes.push({
        id: genId(),
        type: 'symbol',
        value: symVal,
      });
      i++;
      continue;
    }

    if (token.type === 'matrix_open') {
      i++;
      const rows: MathASTNode[][] = [[]];
      let currentRow = 0;

      while (i < tokens.length && tokens[i].type !== 'matrix_close') {
        if (tokens[i].type === 'col_sep') {
          i++;
          continue;
        }
        if (tokens[i].type === 'row_sep') {
          currentRow++;
          rows[currentRow] = [];
          i++;
          continue;
        }

        const grp = parseNextGroupOrToken(tokens, i);
        rows[currentRow].push(grp.node);
        i = grp.nextIdx;
      }

      if (i < tokens.length && tokens[i].type === 'matrix_close') {
        i++;
      }

      nodes.push({
        id: genId(),
        type: 'matrix',
        matrixRows: rows,
      });
      continue;
    }

    if (token.type === 'char') {
      const lastNode = nodes[nodes.length - 1];

      // Check for attached subscript or superscript right after char
      if (i + 1 < tokens.length && (tokens[i + 1].type === 'sub' || tokens[i + 1].type === 'sup')) {
        const nucleus: MathASTNode = {
          id: genId(),
          type: 'text',
          value: token.value,
        };
        i++;

        let subscript: MathASTNode | undefined;
        let superscript: MathASTNode | undefined;

        while (i < tokens.length && (tokens[i].type === 'sub' || tokens[i].type === 'sup')) {
          if (tokens[i].type === 'sub') {
            i++;
            const subGrp = parseNextGroupOrToken(tokens, i);
            subscript = subGrp.node;
            i = subGrp.nextIdx;
          } else if (tokens[i].type === 'sup') {
            i++;
            const supGrp = parseNextGroupOrToken(tokens, i);
            superscript = supGrp.node;
            i = supGrp.nextIdx;
          }
        }

        nodes.push({
          id: genId(),
          type: 'subsup',
          nucleus,
          subscript,
          superscript,
        });
        continue;
      }

      nodes.push({
        id: genId(),
        type: 'text',
        value: token.value,
      });
      i++;
      continue;
    }

    if (token.type === 'group_open') {
      i++;
      const groupTokens: Token[] = [];
      let depth = 1;

      while (i < tokens.length && depth > 0) {
        if (tokens[i].type === 'group_open') depth++;
        else if (tokens[i].type === 'group_close') depth--;

        if (depth > 0) {
          groupTokens.push(tokens[i]);
          i++;
        }
      }
      if (i < tokens.length && tokens[i].type === 'group_close') i++;

      const childNodes = parseTokenList(groupTokens);
      nodes.push({
        id: genId(),
        type: 'group',
        children: childNodes,
      });
      continue;
    }

    i++;
  }

  return nodes;
}

function parseNextGroupOrToken(tokens: Token[], startIdx: number): { node: MathASTNode; nextIdx: number } {
  if (startIdx >= tokens.length) {
    return {
      node: { id: genId(), type: 'text', value: '' },
      nextIdx: startIdx,
    };
  }

  const tok = tokens[startIdx];

  if (tok.type === 'group_open') {
    let depth = 1;
    let i = startIdx + 1;
    const groupTokens: Token[] = [];

    while (i < tokens.length && depth > 0) {
      if (tokens[i].type === 'group_open') depth++;
      else if (tokens[i].type === 'group_close') depth--;

      if (depth > 0) {
        groupTokens.push(tokens[i]);
        i++;
      }
    }
    if (i < tokens.length && tokens[i].type === 'group_close') i++;

    const children = parseTokenList(groupTokens);
    return {
      node: { id: genId(), type: 'group', children },
      nextIdx: i,
    };
  }

  const parsed = parseTokenList([tok]);
  return {
    node: parsed[0] || { id: genId(), type: 'text', value: tok.value },
    nextIdx: startIdx + 1,
  };
}
