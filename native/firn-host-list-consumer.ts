import { 'host-list' as hostList } from './firn-host-list.js';

export function listedHosts(root: string): string {
  const result = hostList(root);
  if (result.status !== 0) throw new Error(result.error);
  return result.output;
}
