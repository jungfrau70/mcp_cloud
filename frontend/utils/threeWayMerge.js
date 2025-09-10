// Simple 3-way merge utility producing merged text with conflict markers when needed.
// Exports merge3(base, local, upstream) -> { merged, conflicts }
// Strategy: line-based LCS on (base vs local) and (base vs upstream), then reconcile.
// Fallback to trivial markers when divergent edits on same region.

function diffLines(aLines, bLines){
  // Return LCS matrix and a function to backtrack to get operations.
  const m = aLines.length, n = bLines.length
  const dp = Array.from({length:m+1}, () => new Array(n+1).fill(0))
  for(let i=1;i<=m;i++){
    for(let j=1;j<=n;j++){
      if(aLines[i-1] === bLines[j-1]) dp[i][j] = dp[i-1][j-1] + 1
      else dp[i][j] = Math.max(dp[i-1][j], dp[i][j-1])
    }
  }
  function backtrack(){
    const ops = []
    let i=m, j=n
    while(i>0 && j>0){
      if(aLines[i-1] === bLines[j-1]){ ops.push({type:'equal', line:aLines[i-1]}); i--; j--; }
      else if(dp[i-1][j] >= dp[i][j-1]){ ops.push({type:'del', line:aLines[i-1]}); i--; }
      else { ops.push({type:'add', line:bLines[j-1]}); j--; }
    }
    while(i>0){ ops.push({type:'del', line:aLines[--i]}) }
    while(j>0){ ops.push({type:'add', line:bLines[--j]}) }
    ops.reverse()
    return ops
  }
  return { ops: backtrack() }
}

export function merge3(base, local, upstream){
  const baseLines = base.split('\n')
  const localLines = local.split('\n')
  const upLines = upstream.split('\n')

  // Fast path: identical local/upstream
  if(local === upstream) return { merged: local, conflicts: 0 }

  // Map lines to indices for quick lookup of unchanged lines
  const baseToLocal = diffLines(baseLines, localLines).ops
  const baseToUp = diffLines(baseLines, upLines).ops

  // Build arrays marking status per base line
  const baseStatusLocal = [] // 'same' | 'changed' | 'deleted'
  const baseStatusUp = []
  let bi=0
  for(const op of baseToLocal){
    if(op.type==='equal'){ baseStatusLocal[bi++] = 'same' }
    else if(op.type==='del'){ baseStatusLocal[bi++] = 'deleted' }
    else if(op.type==='add'){ /* insertion in local, does not advance base index */ }
  }
  bi=0
  for(const op of baseToUp){
    if(op.type==='equal'){ baseStatusUp[bi++] = 'same' }
    else if(op.type==='del'){ baseStatusUp[bi++] = 'deleted' }
    else if(op.type==='add'){ }
  }

  // Reconstruct merged using a simple scan with indices over local & up arrays
  const merged = []
  let conflicts = 0
  let li=0, ui=0, bIndex=0
  while(li < localLines.length || ui < upLines.length){
    const lLine = localLines[li]
    const uLine = upLines[ui]

    // If both exhausted, break
    if(li >= localLines.length && ui >= upLines.length) break

    if(lLine === uLine){
      merged.push(lLine)
      li++; ui++
      continue
    }

    // Simple heuristic: if one side retains a base line unchanged and other changed, prefer changed
    if(lLine === baseLines[bIndex] && uLine !== baseLines[bIndex]){
      merged.push(uLine); ui++; bIndex++; continue
    }
    if(uLine === baseLines[bIndex] && lLine !== baseLines[bIndex]){
      merged.push(lLine); li++; bIndex++; continue
    }

    // Divergent change: emit conflict block
    const blockLocal = lLine !== undefined ? lLine : ''
    const blockUp = uLine !== undefined ? uLine : ''
    merged.push(`<<<<<<< LOCAL`)
    merged.push(blockLocal)
    merged.push(`=======`)
    merged.push(blockUp)
    merged.push(`>>>>>>> UPSTREAM`)
    li++; ui++; conflicts++
  }
  return { merged: merged.join('\n'), conflicts }
}

export default { merge3 }
