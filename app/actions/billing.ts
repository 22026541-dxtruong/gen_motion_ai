'use server';

import { fetchApi } from '@/lib/api';

export async function getBillingCatalogAction() {
  try {
    const data = await fetchApi('/billing/catalog');
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch billing catalog' };
  }
}

export async function createOrderAction(type: 'CREDIT_TOPUP' | 'PRO_SUBSCRIPTION', provider: 'MOMO' | 'PAYOS' | 'BANK_TRANSFER', packageCode?: string) {
  try {
    const data = await fetchApi('/billing/orders', {
      method: 'POST',
      body: JSON.stringify({ type, provider, packageCode }),
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to create order' };
  }
}

export async function getMyOrdersAction() {
  try {
    const data = await fetchApi('/billing/orders/me');
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch orders' };
  }
}

export async function markOrderPaidAction(orderId: string, providerOrderId?: string) {
  try {
    const data = await fetchApi(`/billing/orders/${orderId}/mark-paid`, {
      method: 'POST',
      body: JSON.stringify({ providerOrderId }),
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to mark order as paid' };
  }
}

export async function confirmPayosWebhookAction(webhookUrl?: string) {
  try {
    const data = await fetchApi('/billing/webhooks/payos/confirm', {
      method: 'POST',
      body: JSON.stringify({ webhookUrl }),
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to confirm PayOS webhook' };
  }
}
