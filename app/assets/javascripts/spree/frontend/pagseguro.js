//Insira o código de checkout gerado no Passo 1
var pagsegurCodeSelector = document.querySelector('div[data-pagseguro-code]')
if (pagsegurCodeSelector) {
  var code = pagsegurCodeSelector.dataset.pagseguroCode;
  var callback = {
    success : function(transactionCode) {
      var checkoutPaymentForm = document.querySelector('form.checkout_form_payment');
      var submit = checkout_form_payment.querySelector("input[type='submit']")
      $(submit).trigger('click');
    },
    abort : function() {
      console.log("abortado");
    }
  };
  var isOpenLightbox = PagSeguroLightbox(code, callback);
  if (!isOpenLightbox){
    location.href="https://pagseguro.uol.com.br/v2/checkout/payment.html?code=" + code;
    console.log("Redirecionamento")
  }
}
