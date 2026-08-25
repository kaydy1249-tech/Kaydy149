const sb = supabase.createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY);
let selected = null;

function selectPack(robux, amount) {
  selected = { robux, amount };
  document.getElementById("selected").value = `${robux.toLocaleString("vi-VN")} Robux — ${amount.toLocaleString("vi-VN")}₫`;
  window.scrollTo({ top: document.body.scrollHeight, behavior: "smooth" });
}

async function createOrder() {
  const username = document.getElementById("username").value.trim();
  const out = document.getElementById("result");
  if (!selected || !username) {
    out.style.display = "block";
    out.textContent = "Vui lòng chọn gói và nhập Roblox username.";
    return;
  }
  const code = "RBX-" + Date.now();
  const { error } = await sb.from("orders").insert({
    order_code: code,
    roblox_username: username,
    robux: selected.robux,
    amount_vnd: selected.amount,
    status: "pending_payment"
  });
  out.style.display = "block";
  out.textContent = error
    ? ("Lỗi: " + error.message)
    : `Đã tạo đơn ${code}. Hệ thống sẽ chờ xác nhận thanh toán.`;
}
